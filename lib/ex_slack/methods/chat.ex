defmodule ExSlack.Methods.Chat do
  use ExSlack.Methods.Common

  @method_post_message "chat.postMessage"

  @doc """
  https://api.slack.com/methods/chat.postMessage
  """
  def post_message(token, channel, text, optionals \\ []) when is_binary(text) and is_list(optionals) do
    query = 
      cast(optionals, [:as_user, :attachments, :icon_emoji, :icon_url, :link_names,
                       :parse, :reply_broadcast, :thread_ts, :unfurl_links, :unfurl_media, :username])
      |> Map.put(:token, token)
      |> Map.put(:channel, channel)
      |> Map.put(:text, text)
    "https://slack.com/api/#{@method_post_message}?#{URI.encode_query(query)}"
    |> HTTPoison.get()
    |> handle_response(:message, @method_post_message)
  end
end