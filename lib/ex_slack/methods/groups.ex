defmodule ExSlack.Methods.Groups do
use ExSlack.Methods.Common

@method_list "groups.list"
@method_info "groups.info"

@doc """
https://api.slack.com/methods/groups.info
"""
def info(token, channel, optionals \\ []) when is_list(optionals) do
    query = 
    cast(optionals, [:include_locale])
    |> Map.put(:token, token)
    |> Map.put(:channel, channel)
    "https://slack.com/api/#{@method_info}?#{URI.encode_query(query)}"
    |> HTTPoison.get()
    |> handle_response(:group, @method_info)
end

@doc """
https://api.slack.com/methods/groups.list
"""
def list(token, optionals \\ []) when is_list(optionals) do
    query = 
    cast(optionals, [:cursor, :exclude_archived, :exclude_members, :limit])
    |> Map.put(:token, token)
    "https://slack.com/api/#{@method_list}?#{URI.encode_query(query)}"
    |> HTTPoison.get()
    |> handle_response(:groups, @method_list)
end
end