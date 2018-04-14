defmodule ExSlack.WebApi.Chat do
  use ExSlack.WebApi.Common

  @method_post_message "chat.postMessage"
  @method_update "chat.update"
  @method_post_ephemeral "chat.postEphemeral"

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

  @doc """
  https://api.slack.com/methods/chat.postEphemeral
  """
  def post_ephemeral(token, channel, text, user, optionals \\ []) when is_binary(text) and is_list(optionals) do
    query = 
      cast(optionals, [:as_user, :attachments, :link_names, :parse])
      |> Map.put(:token, token)
      |> Map.put(:channel, channel)
      |> Map.put(:text, text)
      |> Map.put(:user, user)
    "https://slack.com/api/#{@method_post_ephemeral}?#{URI.encode_query(query)}"
    |> HTTPoison.get()
    |> handle_response(:message, @method_post_ephemeral)
  end

  @doc """
  https://api.slack.com/methods/chat.update
  """
  def update(token, channel, text, ts, optionals \\ []) when is_binary(text) and is_list(optionals) do
    query = 
      cast(optionals, [:as_user, :attachments, :link_names, :parse])
      |> Map.put(:token, token)
      |> Map.put(:channel, channel)
      |> Map.put(:text, text)
      |> Map.put(:ts, ts)
    "https://slack.com/api/#{@method_update}?#{URI.encode_query(query)}"
    |> HTTPoison.get()
    |> handle_response(:message, @method_update)
  end
end