dummy_main = """
main = do
  putStrLn "Hello, World!"
"""

if length(System.argv()) == 0 do
  IO.puts("Usage: elixir validator.exs <path to haskell file>")
  System.stop(1)
end

if File.dir?("variants") do
  IO.puts("Removing old variants directory...")
  File.rm_rf("variants")
end

IO.puts("Generating variants...")
case System.cmd("stack", ["run", System.argv() |> hd()]) do
  {_, 0} ->
    files = File.ls!("variants")
    IO.puts("Success! Generated #{length(files) - 1} variants.")

    for file <- files, file =~ ~r/v\d+\.hs/ do
      case System.cmd("ghc", ["-fno-code", "variants/#{file}"], stderr_to_stdout: true) do
        {_ ,   0} -> IO.puts("File #{file} type checks.")
        {err,  1} ->
          if err =~ ~r"The IO action (`|‘|')main('|’|`) is not defined in module" do
            File.write("variants/main_#{file}", File.read!("variants/#{file}") <> dummy_main)
            case System.cmd("ghc", ["-fno-code", "variants/main_#{file}"], stderr_to_stdout: true) do
              {_ ,   0} -> IO.puts("Variant #{file} type checks.")
              {_err, 1} ->
                IO.puts("Variant #{file} failed type checking. Removing...")
                File.rm("variants/#{file}")
            end
            File.rm("variants/main_#{file}")
          else
            IO.puts("Variant #{file} failed type checking. Removing...")
            File.rm("variants/#{file}")
          end
      end
    end
  _ -> IO.puts("Error - variants could not be generated.")
end
