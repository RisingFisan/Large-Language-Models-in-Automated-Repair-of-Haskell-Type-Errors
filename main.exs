Mix.install([:httpoison, :jason])

defmodule Main do

  def type_checks?(file) do
    dummy_main = """

    main = do
      putStrLn "Hello, World!"
    """

    case System.cmd("ghc", ["-fno-code", file], stderr_to_stdout: true) do
      {_ ,   0} -> true
      {err,  1} ->
        if err =~ ~r"The IO action (`|‘|')main('|’|`) is not defined in module" do
          new_file = String.replace(file, ~r".hs$", "_main.hs")
          File.write(new_file, File.read!(file) <> dummy_main)
          {_output, status} = System.cmd("ghc", ["-fno-code", new_file], stderr_to_stdout: true)
          File.rm(new_file)
          status == 0
        else
          false
        end
    end
  end

  def ask_gpt(mode, code) do
    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{File.read!(".openai_api_key") |> String.trim()}"}
    ]

    system_msg = case mode do
      :insert -> "Fill in the '<INSERT>' tag. Answer only with the inserted text."
      :fix -> "Fix this Haskell program. Answer only with the fixed program."
    end

    case HTTPoison.post("https://api.openai.com/v1/chat/completions", Jason.encode!(%{
      "model" => "gpt-4",
      "temperature" => 0,
      "messages" => [
        %{
          "role" => "system",
          "content" => system_msg
        },
        %{
          "role" => "user",
          "content" => code
        },
      ]
    }), headers, recv_timeout: 30000) do
      {:ok, %{body: body}} ->
        {:ok, Jason.decode!(body)["choices"] |> Enum.map(fn choice -> choice["message"]["content"] end)}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  def check_fix(qc_file, fixed_code) do
    qc_template = """
    import Test.QuickCheck
    import System.Exit

    #{qc_file}

    main = do
        r <- quickCheckResult prop
        case r of
            Success {} -> return ()
            _ -> exitWith (ExitFailure 1)

    """

    imports = Regex.scan(~r"^import\s.*\n"m, fixed_code)
    fixed_code = String.replace(fixed_code, ~r"^import\s.*\n"m, "")

    qc = Enum.join(imports) <> qc_template <> "\n" <> fixed_code

    File.write!("temp.hs", qc)
    result = case System.cmd("stack", ["runghc", "temp.hs"], stderr_to_stdout: true) do
      {_ ,   0} -> :ok
      {err,  1} -> {:error, err}
    end
    File.rm("temp.hs")
    result
  end

  def main do

    gen_variants = not Enum.any?(["--fix", "--no-variants", "-nv"], & &1 in System.argv())

    no_typecheck = Enum.any?(["--no-typecheck", "-nt"], & &1 in System.argv())

    no_gpt = Enum.any?(["--no-gpt", "-ng", "--no-fix"], & &1 in System.argv())

    with {:ok, filename} <- (if length(System.argv()) == 0, do: {:error, "No file or path specified."}, else: {:ok, System.argv() |> hd()}),
        {:ok, _} <- (if File.exists?(filename) and not File.dir?(filename), do: {:ok, nil}, else: {:error, "'#{filename}' does not exist or is not a file."}),
        {:ok, _} <- (if type_checks?(filename), do: {:error, "'#{filename}' does not contain any type errors."}, else: {:ok, nil}) do

      if gen_variants do
        if File.dir?("variants") do
          IO.puts("Removing old variants directory...")
          File.rm_rf("variants")
        end
        File.mkdir!("variants")
      end

      file_noext = Regex.replace(~r".hs$", filename, "")

      file_content = File.read!(filename)

      qc_content = case Regex.run(~r"{-QC\s*(.*?)\s*QC-}"s, file_content) do
        [_, x] -> x
        nil -> nil
      end

      files = if gen_variants do
        IO.puts("Generating variants...")
        {content, test_cases} = case file_content |> String.split(~r/^\s*--\s*\[TEST CASES?\].*?\r?\n/m) do
          [c] -> {c, nil}
          [c, t] -> {c, t}
        end
        File.write!("variants/original.hs", content)
        case System.cmd("stack", ["run", "variants/original.hs"]) do
          {_, 0} ->
            File.rm!("variants/original.hs")
            files = File.ls!("variants")

            if test_cases != nil do
              Enum.map(files, fn file ->
                f = File.open!("variants/" <> file, [:append])
                IO.write(f, test_cases)
                File.close(f)
              end)
            end

            IO.puts("Success! Generated #{length(files)} variants.")
            files

          {error, _} ->
            IO.puts("Error - variants could not be generated.\nOriginal error message:")
            IO.puts(error)
          end
        else
          [filename]
        end

        if not no_typecheck do
          i = Enum.reduce_while(files, 1, fn file, i ->
            content = cond do
              not gen_variants -> File.read!(file)
              type_checks?("variants/#{file}") ->
                IO.puts("Variant #{file} type checks.")
                File.read!("variants/#{file}") |> String.replace(~r"`?undefined`?", "<INSERT>")
              true ->
                IO.puts("Variant #{file} does not type check.")
                File.rm("variants/#{file}")
                nil
            end

            if content != nil and not no_gpt do
              if gen_variants, do: File.rm("variants/#{file}")

              case ask_gpt((if gen_variants, do: :insert, else: :fix), content) do
                {:ok, choices} ->
                  if qc_content != nil do
                    j = Enum.reduce_while(choices, i, fn choice, _ ->
                      possible_fix = if gen_variants do
                        String.replace(content, "<INSERT>", choice)
                      else
                        choice
                      end

                      IO.puts("Trying:\n#{possible_fix}\n---")

                      case check_fix(qc_content, possible_fix) do
                        :ok ->
                          IO.puts("Fixed!")
                          File.write!(file_noext <> "_fixed.hs", possible_fix)
                          {:halt, i+1}
                        {:error, _reason} ->
                          IO.puts("Error - fix does not work.")
                          {:cont, i}
                      end
                    end)
                    if j == i do
                      {:cont, i}
                    else
                      {:halt, j}
                    end
                  else
                    IO.puts("QuickCheck prop not found. Generating possible fix#{if length(choices) > 1, do: "es", else: ""}...")
                    j = Enum.reduce(choices, i, fn choice, i ->
                      File.write!(file_noext <> "_fix_#{i}.hs", String.replace(content, "<INSERT>", choice))
                      i+1
                    end)
                    {:cont, j}
                  end
                {:error, reason} ->
                  IO.puts("Error when communicating with GPT - #{reason}")
                  {:cont, i}
              end
            else
              {:cont, i}
            end
          end)
          if i == 1, do: IO.puts("Unable to fix type error.")
          if not no_gpt, do: File.rm_rf!("variants")
        end
    else
      {:error, reason} -> IO.puts("Error - #{reason}")
    end
  end
end

Main.main()
