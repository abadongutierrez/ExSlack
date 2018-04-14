defmodule ExSlack.EventsApiBot do
    use GenServer

    alias ExSlack.WebApi.Chat, as: Chat
  
    # Client API
  
    def start_link(client_id, secret_id, code, handler) do
      case ExSlack.WebApi.Oauth.access(client_id, secret_id, code) do
        {:ok, result} ->
          {:ok, pid} = GenServer.start_link(__MODULE__, %{
              access_token: result.bot.bot_access_token,
              bot_id: result.bot.bot_user_id,
              handler: handler,
              bot_state: %{}
          })
        {:error, reason} -> {:error, reason}
      end
    end

    def process_event(pid, event) do
      GenServer.cast(pid, {:event, event})
      :ok
    end

    def process_interactive_message(pid, payload) do
      GenServer.cast(pid, {:interactive_message, payload})
      :ok
    end
  
    # GenServer Callbacks
  
    def init(args) do
      {:ok, args}
    end
  
    def handle_cast({:event, event}, state) do
      result = state.handler.handle_event(event, state |> build_bot_state)
      bot_state = case result do
        _ -> if Map.has_key?(state, :bot_state), do: state.bot_state, else: %{}
      end
      {:noreply, %{state | bot_state: bot_state}}
    end

    def handle_cast({:interactive_message, event}, state) do
      result = state.handler.handle_interactive_message(event, state |> build_bot_state)
      bot_state = case result do
        _ -> if Map.has_key?(state, :bot_state), do: state.bot_state, else: %{}
      end
      {:noreply, %{state | bot_state: bot_state}}
    end

    defp build_bot_state(state) do
      %{token: state.access_token, bot_id: state.bot_id}
    end
  
  end