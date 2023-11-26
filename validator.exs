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
      :insert -> "Fill in the <INSERT> tag. Answer must only contain the inserted text."
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
    File.write!("variants/temp.hs", File.read!(qc_file) |> String.replace("-- [INSERT]\n", fixed_code))
    result = case System.cmd("stack", ["runghc", "variants/temp.hs"], stderr_to_stdout: true) do
      {_ ,   0} -> :ok
      {err,  1} -> {:error, err}
    end
    File.rm("variants/temp.hs")
    result
  end

  def main do

    no_variants = "--no-variants" in System.argv() || "-nv" in System.argv()

    with {:ok, filepath} <- (if length(System.argv()) == 0, do: {:error, "No file or path specified."}, else: {:ok, System.argv() |> hd()}),
        {:ok, _} <- (if File.exists?(filepath), do: {:ok, nil}, else: {:error, "File #{filepath} does not exist."}) do

      if not no_variants and File.dir?("variants") do
        IO.puts("Removing old variants directory...")
        File.rm_rf("variants")
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
        Regex.run(~r/.*(?=\/)/, filepath) |> hd()
      end

      if no_variants do
        IO.puts("Attempting to fix file without type checking...")
        if not File.dir?("variants"), do: File.mkdir!("variants")
        case ask_gpt(:fix, File.read!(filename)) do
          {:ok, choices} ->
            if is_path? and File.exists?(filepath <> "/qc.hs") and File.read!(filepath <> "/qc.hs") |> String.contains?("[INSERT]") do
              case Enum.reduce_while(choices, :err, fn choice, _ ->
                IO.puts("Possible fix found:\n-----\n#{choice}\n-----\nTesting fix...")
                case check_fix(filepath <> "/qc.hs", choice) do
                  :ok ->
                    File.write!(filepath <> "/fixed.hs", choice)
                    {:halt, :ok}
                  {:error, _reason} ->
                    {:cont, :err}
                end
              end) do
                :ok -> IO.puts("Fixed!")
                :err -> IO.puts("Error - could not fix file.")
              end
            else
              IO.puts("QuickCheck file not found. Generating all possible fixes...")
              Enum.reduce(choices, 1, fn choice, i ->
                File.write!(filepath <> "/fix_#{i}.hs", choice)
                i+1
              end)
            end
          {:error, reason} ->
            IO.puts("Error when communicating with GPT - #{reason}")
        end
      else
        IO.puts("Generating variants...")
        case System.cmd("stack", ["run", filename]) do
          {_, 0} ->
            files = File.ls!("variants")
            IO.puts("Success! Generated #{length(files) - 1} variants.")

            # for file <- files, file =~ ~r/v\d+\.hs/ do
            Enum.reduce_while(files, 1, fn file, i ->
              if type_checks?(file) do
                IO.puts("Variant #{file} type checks.")

                content = File.read!("variants/#{file}") |> String.replace(~r"`?undefined`?", "<INSERT>")
                IO.puts(content)

                File.rm("variants/#{file}")

                case ask_gpt(:insert, content) do
                  {:ok, choices} ->
                    if is_path? and File.exists?(filepath <> "/qc.hs") and File.read!(filepath <> "/qc.hs") |> String.contains?("[INSERT]") do
                      j = Enum.reduce_while(choices, i, fn choice, _ ->
                        IO.puts("Trying '#{choice}'...")

                        possible_fix = String.replace(content, "<INSERT>", choice)

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
                      IO.puts("QuickCheck file not found. Generating all possible fixes...")
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
                IO.puts("Variant #{file} does not type check.")
                File.rm("variants/#{file}")
                {:cont, i}
              end
            end)
            File.rm_rf!("variants")
          _ -> IO.puts("Error - variants could not be generated.")
        end
      end
    else
      {:error, reason} -> IO.puts("Error - #{reason}")
    end
  end
end

Main.main()
