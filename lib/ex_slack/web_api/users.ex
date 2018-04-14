defmodule ExSlack.WebApi.Users do
  use ExSlack.WebApi.Common

  @method_info "users.info"
  @method_list "users.list"

  @doc """
  Gets information about a user.

  Receives the slack `token` and the slack `user id`.

  Slack documentation here: https://api.slack.com/methods/users.info

  ## Optionals

  List of optional arguments as a keyword list.
  Read about optional arguments for method `users.list` here: https://api.slack.com/methods/users.list.
  
  Right now supported optionals are: `:include_locale`.
  """
  def info(token, user, optionals \\ []) when is_list(optionals) do
    query = 
      cast(optionals, [:include_locale])
      |> Map.put(:token, token)
      |> Map.put(:user, user)
    "https://slack.com/api/#{@method_info}?#{URI.encode_query(query)}"
    |> HTTPoison.get()
    |> handle_response(:user, @method_info)
  end

  @doc """
  Lists all users in a Slack team.

  Receives the slack `token`.  

  Slack documentation here: https://api.slack.com/methods/users.list

  ## Optionals

  List of optional arguments as a keyword list.
    Read about optional arguments for method `users.list` here: https://api.slack.com/methods/users.list.
  
  Right now supported optionals are: `:cursor`, `:include_locale`, `:limit` & `:presence`.
  """
  def list(token, optionals \\ []) when is_list(optionals) do
    query = 
      cast(optionals, [:cursor, :include_locale, :limit, :presence])
      |> Map.put(:token, token)
    "https://slack.com/api/#{@method_list}?#{URI.encode_query(query)}"
    |> HTTPoison.get()
    |> handle_response([:members, :response_metadata], @method_list)
  end
end