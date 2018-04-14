defmodule ExSlack.WebApi.Oauth do
  use ExSlack.WebApi.Common

  @method_access "oauth.access"

  @doc """
  https://api.slack.com/methods/oauth.access
  """
  def access(client_id, client_secret, code, optionals \\ []) when is_list(optionals) do
    query = 
      cast(optionals, [:redirect_uri])
      |> Map.put(:client_id, client_id)
      |> Map.put(:client_secret, client_secret)
      |> Map.put(:code, code)
    "https://slack.com/api/#{@method_access}"
      |> HTTPoison.post({:form, Map.to_list(query)}, %{"Content-type" => "application/x-www-form-urlencoded"})
      |> handle_response(@method_access)
  end
end