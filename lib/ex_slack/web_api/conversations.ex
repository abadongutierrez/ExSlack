defmodule ExSlack.WebApi.Conversations do
  use ExSlack.WebApi.Common

  @method_open "conversations.open"

  @doc """
  https://api.slack.com/methods/conversations.open
  """
  def open(token, optionals \\ []) when is_list(optionals) do
    query =
      cast(optionals, [:channel, :return_im, :users])
      |> Map.put(:token, token)
    "https://slack.com/api/#{@method_open}"
      |> HTTPoison.post({:form, Map.to_list(query)}, %{"Content-type" => "application/x-www-form-urlencoded"})
      |> handle_response(:channel, @method_open)
  end
end
