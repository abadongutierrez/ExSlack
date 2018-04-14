defmodule ExSlack.WebBot do
  use GenServer

  # Client API

  def start_link(client_id, secret_id, code, handler) do
    case ExSlack.WebApi.Oauth.access(client_id, secret_id, code) do
      {:ok, result} ->
        {:ok, pid} = GenServer.start_link(__MODULE__, %{
            access_token: result.bot.bot_access_token,
            bot_id: result.bot.bot_user_id,
            handler: handler
        })
      {:error, reason} -> {:error, reason}
    end
  end

  def handle_event(pid, %{"event" => event} = message) do
    GenServer.cast(pid, {:event, event})
    :ok
  end

  def handle_event(pid, _message) do
    :ok
  end

  def handle_interactive_message(pid, payload) do
    GenServer.cast(pid, {:interactive_message, payload})
  end

  # Server API

  def init(args) do
    {:ok, args}
  end

  def handle_cast({:event, event}, state) do
    state.handler.handle_event(event, %{token: state.access_token})
    {:noreply, state}
  end

  def handle_cast({:interactive_message, payload}, state) do
    state.handler.handle_interactive_message(payload, %{token: state.access_token})
    {:noreply, state}
  end

end