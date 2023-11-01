dummy_main = """
main = do
  putStrLn "Hello, World!"
"""

case File.ls("variants") do
  {:ok, files} ->
    IO.puts("Found #{length(files)} files")

    for file <- files, file =~ ~r/v\d+\.hs/ do
      case System.cmd("ghc", ["-fno-code", "variants/#{file}"], stderr_to_stdout: true) do
        {_ ,   0} -> IO.puts("File #{file} type checks.")
        {err,  1} ->
          if err =~ ~r"The IO action (`|‘|')main('|’|`) is not defined in module" do
            File.write("variants/main_#{file}", File.read!("variants/#{file}") <> dummy_main)
            case System.cmd("ghc", ["-fno-code", "variants/main_#{file}"], stderr_to_stdout: true) do
              {_ ,   0} -> IO.puts("File #{file} type checks.")
              {_err, 1} ->
                IO.puts("File #{file} failed type checking. Removing...")
                File.rm("variants/#{file}")
            end
            File.rm("variants/main_#{file}")
          else
            IO.puts("File #{file} failed type checking. Removing...")
            File.rm("variants/#{file}")
          end
      end
    end
  {:error, _} -> IO.puts("Error - variants folder not found")
end
