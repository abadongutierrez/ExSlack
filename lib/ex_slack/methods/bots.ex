defmodule ExSlack.Methods.Bots do
  use ExSlack.Methods.Common

  @method_info "bots.info"

  def info(token, optionals \\ []) when is_list(optionals) do
    query = 
      cast(optionals, [:bot])
      |> Map.put(:token, token)
    query = %{"token" => token}
    "https://slack.com/api/#{@method_info}?#{URI.encode_query(query)}"
    |> HTTPoison.get()
    |> handle_response(:bot, @method_info)
  end

end