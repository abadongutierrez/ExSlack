defmodule ExSlack.WebApi.Im do
  use ExSlack.WebApi.Common

  @method_open "im.open"
  @method_close "im.close"

  @doc """
  Opens a direct message channel.

  Receives the slack `token` and the slack `user id`.

  Slack documentation here: https://api.slack.com/methods/im.open

  ## Optionals

  List of optional arguments as a keyword list.
  Read about optional arguments for method `im.open` here: https://api.slack.com/methods/im.open.
  
  Right now supported optionals are: `:include_locale` & `:return_im`.
  """
  def open(token, user, optionals \\ []) when is_list(optionals) do
    query = 
      cast(optionals, [:include_locale, :return_im])
      |> Map.put(:token, token)
      |> Map.put(:user, user)
    "https://slack.com/api/#{@method_open}?#{URI.encode_query(query)}"
    |> HTTPoison.get()
    |> handle_response([:channel, :no_op, :already_open], @method_open)
  end

  def close(token, channel) do
    query = %{}
      |> Map.put(:token, token)
      |> Map.put(:channel, channel)
    "https://slack.com/api/#{@method_close}"
      |> HTTPoison.post({:form, Map.to_list(query)}, %{"Content-type" => "application/x-www-form-urlencoded"})
      |> handle_response([:no_op, :already_closed], @method_close)
  end
end