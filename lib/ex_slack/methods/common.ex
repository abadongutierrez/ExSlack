defmodule ExSlack.Methods.Common do
    
  defmacro __using__(_) do
    quote do
      defp handle_response({:ok, %HTTPoison.Response{body: body}}, type_atoms, name) when is_list(type_atoms) do
        case Poison.Parser.parse(body, keys: :atoms) do
          {:ok, %{ok: true} = result} ->
            {:ok, Enum.reduce(type_atoms, %{}, fn(key, acc) ->
              if Map.has_key?(result, key), do: Map.put(acc, key, Map.get(result, key)), else: acc
            end)}
          {:ok, %{ok: false, error: reason}} -> {:error, reason}
          {:error, _} -> {:error, "Error parsing body"}
          _ -> {:error, "Unknown #{name} response"}
        end  
      end

      defp handle_response({:ok, %HTTPoison.Response{body: body}}, type_atom, name) do
        case Poison.Parser.parse(body, keys: :atoms) do
          {:ok, %{:ok => true, ^type_atom => type}} -> {:ok, Map.put(%{}, type_atom, type)}
          {:ok, %{ok: false, error: reason}} -> {:error, reason}
          {:error, _} -> {:error, "Error parsing body"}
          _ -> {:error, "Unknown #{name} response"}
        end  
      end
      
      defp handle_response(error, _type_atom, _name), do: error

      defp cast(optinals, key_list) do
        Enum.reduce(key_list, %{}, fn(key, acc) -> 
          case Keyword.fetch(optinals, key) do
            {:ok, value} ->
              Map.put(acc, key, value)
            :error ->
              acc
          end
        end)
      end

    end
  end
end