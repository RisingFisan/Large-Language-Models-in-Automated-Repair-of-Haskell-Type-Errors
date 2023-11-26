Mix.install([:httpoison, :jason])

defmodule Main do
  def main do
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
          "content" => "Fix this Haskell program. Answer only with the fixed program."
        },
        %{
          "role" => "user",
          "content" => """
                       tails :: [a] -> [[a]]
                       tails [] = [[]]
                       tails l = l ++ tails (tail l)
                       """
        },
      ]
    }), headers, recv_timeout: 30000) do
      {:ok, %{body: body}} ->
        IO.puts(body)
        IO.puts("Fixed program:")
        for choice <- Jason.decode!(body)["choices"] do
          IO.puts(choice["message"]["content"])
        end
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts("Error - #{reason}")
    end
  end
end

Main.main()
