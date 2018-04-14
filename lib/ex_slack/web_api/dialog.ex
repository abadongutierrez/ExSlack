defmodule ExSlack.WebApi.Dialog do
  use ExSlack.WebApi.Common

  @method_open "dialog.open"

  @doc """
  https://api.slack.com/methods/dialog.open
  """
  def open(token, dialog, trigger_id) when is_binary(dialog) do
    query = %{}
      |> Map.put(:token, token)
      |> Map.put(:dialog, dialog)
      |> Map.put(:trigger_id, trigger_id)
    "https://slack.com/api/#{@method_open}"
      |> HTTPoison.post({:form, Map.to_list(query)}, %{"Content-type" => "application/x-www-form-urlencoded"})
      |> handle_response(:message, @method_open)
  end
end