Mix.install([:httpoison, :jason])

defmodule Main do

  def type_checks?(file) do
    dummy_main = """

    main = do
      putStrLn "Hello, World!"
    """

    case System.cmd("ghc", ["-fno-code", "variants/#{file}"], stderr_to_stdout: true) do
      {_ ,   0} -> true
      {err,  1} ->
        if err =~ ~r"The IO action (`|‘|')main('|’|`) is not defined in module" do
          File.write("variants/main_#{file}", File.read!("variants/#{file}") <> dummy_main)
          {_output, status} = System.cmd("ghc", ["-fno-code", "variants/main_#{file}"], stderr_to_stdout: true)
          File.rm("variants/main_#{file}")
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
    imports = Regex.scan(~r"^import\s.*\n"m, fixed_code)
    fixed_code = String.replace(fixed_code, ~r"^import\s.*\n"m, "")

    qc = Enum.join(imports) <> File.read!(qc_file) <> "\n" <> fixed_code

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

    with {:ok, filepath} <- (if length(System.argv()) == 0, do: {:error, "No file or path specified."}, else: {:ok, System.argv() |> hd()}),
        {:ok, _} <- (if File.exists?(filepath), do: {:ok, nil}, else: {:error, "File #{filepath} does not exist."}) do

      if gen_variants do
        if File.dir?("variants") do
          IO.puts("Removing old variants directory...")
          File.rm_rf("variants")
        end
        File.mkdir!("variants")
      end

      is_path? = File.dir?(filepath)

      filename = if is_path? do
        filepath <> "/original.hs"
      else
        filepath
      end

      filepath = if is_path? do
        filepath
      else
        case Regex.run(~r/.*(?=\/)/, filepath) do
          [ h | _ ] -> h
          nil -> "."
        end
      end

      files = if gen_variants do
        IO.puts("Generating variants...")
        {content, test_cases} = case (File.read!(filename) |> String.split(~r/^\s*--\s*\[TEST CASES?\].*?\r?\n/m)) do
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
          Enum.reduce_while(files, 1, fn file, i ->
            content = cond do
              not gen_variants -> File.read!(file)
              type_checks?(file) ->
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
                  if is_path? and File.exists?(filepath <> "/qc.hs") do # and File.read!(filepath <> "/qc.hs") |> String.contains?("[INSERT]") do
                    j = Enum.reduce_while(choices, i, fn choice, _ ->
                      possible_fix = if gen_variants do
                        String.replace(content, "<INSERT>", choice)
                      else
                        choice
                      end

                      IO.puts("Trying '#{possible_fix}'...")

                      case check_fix(filepath <> "/qc.hs", possible_fix) do
                        :ok ->
                          IO.puts("Fixed!")
                          File.write!(filepath <> "/fixed.hs", possible_fix)
                          {:halt, i+1}
                        {:error, _reason} ->
                          IO.puts("Error - fix '#{choice}' does not work.")
                          {:cont, i}
                      end
                    end)
                    if j == i do
                      {:cont, i}
                    else
                      {:halt, j}
                    end
                  else
                    IO.puts("QuickCheck file not found. Generating possible fix#{if length(choices) > 1, do: "es", else: ""}...")
                    j = Enum.reduce(choices, i, fn choice, i ->
                      File.write!(filepath <> "/fix_#{i}.hs", String.replace(content, "<INSERT>", choice))
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
          if not no_gpt, do: File.rm_rf!("variants")
        end
    else
      {:error, reason} -> IO.puts("Error - #{reason}")
    end
  end
end

Main.main()
