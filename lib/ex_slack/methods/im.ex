defmodule ExSlack.Methods.Im do
  use ExSlack.Methods.Common

  @method_open "im.open"

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
end