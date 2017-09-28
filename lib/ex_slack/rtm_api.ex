defmodule ExSlack.RtmApi do
    
  def connect(token) do
    "https://slack.com/api/rtm.connect?token=#{token}"
    |> HTTPoison.get()
    |> handle_connect_response
  end

  defp handle_connect_response({:ok, %HTTPoison.Response{body: body}}) do
    case Poison.Parser.parse(body, keys: :atoms) do
    {:ok, %{ok: true} = json} -> {:ok, json}
    {:ok, %{ok: false, error: reason}} -> {:error, reason}
    {:error, _} -> {:error, "Error parsing body"}
    _ -> {:error, "Unknown Slack RTM API response"}
    end
  end

  defp handle_connect_response(error), do: error
end