defmodule ExSlack.WebApi.Channels do
  use ExSlack.WebApi.Common

  @method_list "channels.list"
  @method_info "channels.info"

  @doc """
  https://api.slack.com/methods/channels.info
  """
  def info(token, channel, optionals \\ []) when is_list(optionals) do
    query = 
      cast(optionals, [:include_locale])
      |> Map.put(:token, token)
      |> Map.put(:channel, channel)
    "https://slack.com/api/#{@method_info}?#{URI.encode_query(query)}"
    |> HTTPoison.get()
    |> handle_response(:channel, @method_info)
  end

  @doc """
  https://api.slack.com/methods/channels.list
  """
  def list(token, optionals \\ []) when is_list(optionals) do
    query = 
      cast(optionals, [:cursor, :exclude_archived, :exclude_members, :limit])
      |> Map.put(:token, token)
    "https://slack.com/api/#{@method_list}?#{URI.encode_query(query)}"
    |> HTTPoison.get()
    |> handle_response(:channels, @method_list)
  end
end