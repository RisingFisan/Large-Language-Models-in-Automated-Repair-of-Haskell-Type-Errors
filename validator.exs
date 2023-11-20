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

  def gpt_complete(code) do
    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{File.read!(".openai_api_key") |> String.trim()}"}
    ]

    case HTTPoison.post("https://api.openai.com/v1/chat/completions", Jason.encode!(%{
      "model" => "gpt-4",
      "temperature" => 0,
      "messages" => [
        %{
          "role" => "system",
          "content" => "Fill in the <INSERT> tag. Answer must only contain the inserted text."
        },
        %{
          "role" => "user",
          "content" => code
        },
      ]
    }), headers, recv_timeout: 30000) do
      {:ok, %{body: body}} ->
        # IO.puts(body)
        # IO.puts("Fixed program:")
        # for choice <- Jason.decode!(body)["choices"] do
        #   IO.puts(choice["message"]["content"])
        # end
        {:ok, Jason.decode!(body)["choices"] |> Enum.map(fn choice -> choice["message"]["content"] end)}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  def check_fix(filename, fixed_code) do
    qc_file = String.replace(filename, ".hs", "_qc.hs")
    File.write!("variants/temp.hs", File.read!(qc_file) |> String.replace("-- [INSERT]\n", fixed_code))
    result = case System.cmd("stack", ["runghc", "variants/temp.hs"]) do
      {_ ,   0} -> :ok
      {err,  1} -> {:error, err}
    end
    File.rm("variants/temp.hs")
    result
  end

  def main do

    with {:ok, filename} <- (if length(System.argv()) == 0, do: {:error, "No file specified."}, else: {:ok, System.argv() |> hd()}),
        {:ok, _} <- (if File.exists?(filename), do: {:ok, nil}, else: {:error, "File #{filename} does not exist."}) do

      if File.dir?("variants") do
        IO.puts("Removing old variants directory...")
        File.rm_rf("variants")
      end

      IO.puts("Generating variants...")
      case System.cmd("stack", ["run", System.argv() |> hd()]) do
        {_, 0} ->
          files = File.ls!("variants")
          IO.puts("Success! Generated #{length(files) - 1} variants.")

          # for file <- files, file =~ ~r/v\d+\.hs/ do
          Enum.reduce_while(files, :ok, fn file, _ ->
            if type_checks?(file) do
              IO.puts("Variant #{file} type checks.")

              content = File.read!("variants/#{file}") |> String.replace(~r"`?undefined`?", "<INSERT>")
              IO.puts(content)

              File.rm("variants/#{file}")

              # case gpt_complete(content) do
              #   {:ok, choices} ->
              #     IO.puts("Completions:")
              #     IO.inspect(choices)
              #   {:error, reason} ->
              #     IO.puts("Error when communicating with GPT - #{reason}")
              # end

              possible_fix = String.replace(content, "<INSERT>", ":")


              case check_fix(filename, possible_fix) do
                :ok ->
                  IO.puts("Fixed!")
                  File.write!("variants/fixed.hs", possible_fix)
                  {:halt, nil}
                {:error, reason} ->
                  IO.puts("Error - #{reason}")
                  {:cont, nil}
              end

            else
              IO.puts("Variant #{file} does not type check.")
              File.rm("variants/#{file}")
              {:cont, nil}
            end
          end)
        _ -> IO.puts("Error - variants could not be generated.")
      end
    else
      {:error, reason} -> IO.puts("Error - #{reason}")
    end
  end
end

Main.main()
