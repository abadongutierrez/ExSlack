defmodule ExSlack.EventsApiBot do
  @moduledoc """
  GenServer Bot using the Slack Events API.
  """

  use GenServer

  require Logger

  # Client API

  @doc """
  Starts the GenServer Bot.

  * `verification_token`.
  * `team_id`. Slack Team ID where the Bot is installed.
  * `bot_user_id`. Slack Bot ID.
  * `bot_access_token`. Slack Bot Access Token.
  * `handler`. Name of the module that will handle Bot messages.
  """
  def start_link(verification_token, team_id, bot_user_id, bot_access_token, handler) do
    GenServer.start_link(__MODULE__, %{
      verification_token: verification_token,
      access_token: bot_access_token,
      bot_id: bot_user_id,
      team_id: team_id,
      handler: handler,
      bot_state: %{},
      users_state: %{}
    })
  end

  @doc """
  Process Slack Event.

  * `pid`. Process ID of the Bot GenServer.
  * `event`. Map with the Slack Event information.
  """
  def process_event(pid, event) do
    event_str = "{team_id: #{event["team_id"]}, event_id: #{event["event_id"]}, type: #{event["type"]}, token: #{event["token"]}}"
    Logger.info "Processing event #{event_str} ..."
    IO.inspect event, label: "Slack Event"
    # TODO: verify `verification_token` vs event["token"]
    if contains_key_and_value?(event, "event") and is_valid_token(pid, event["token"]) do
      GenServer.cast(pid, {:event, event})
    else
      Logger.warn "Event #{event["event_id"]} not processed"
    end
    :ok
  end

  defp is_valid_token(pid, token) do
    GenServer.call(pid, {:token_verification, token})
  end

  def process_interactive_message(pid, payload) do
    GenServer.cast(pid, {:interactive_message, payload})
    :ok
  end

  # GenServer Callbacks

  def init(args) do
    {:ok, args}
  end

  def handle_call({:token_verification, token}, _from, state) do
    {:reply, token == state.verification_token, state}
  end

  def handle_cast({:event, dispatched_event}, state) do
    event = dispatched_event["event"]
    team_id = if contains_key_and_value?(dispatched_event, "team_id"), do: dispatched_event["team_id"], else: nil
    user_id = if contains_key_and_value?(event, "user"), do: event["user"], else: nil
    prev_user_state = get_user_state_or_empty(dispatched_event, state)
    bot_state = build_bot_state(state)

    IO.inspect prev_user_state, label: "prev_user_state 1"

    # TODO is it possible to update bot state and user state at the same time?
    {new_bot_state, new_users_state} = case state.handler.handle_event(event, prev_user_state, bot_state) do
      {:user_state, new_user_state} ->
        Logger.info "Setting user_state for user_id [#{user_id}] from team_id [#{team_id}]"
        updated_users_state = update_user_state(state.users_state, build_user_state_key(team_id, user_id), prev_user_state, new_user_state)
        IO.inspect prev_user_state, label: "prev_user_state 2"
        IO.inspect updated_users_state, label: "updated_users_state"
        {
          bot_state_or_empty(state),
          update_user_state(state.users_state, build_user_state_key(team_id, user_id), prev_user_state, new_user_state)
        }
      _ ->
        {
          bot_state_or_empty(state),
          users_state_or_empty(state)
        }
    end
    IO.inspect new_bot_state, label: "New bot state:"
    IO.inspect new_users_state, label: "New user state:"
    {:noreply, %{state | bot_state: new_bot_state, users_state: new_users_state}}
  end

  def handle_cast({:interactive_message, event}, state) do
    result = state.handler.handle_interactive_message(event, build_bot_state(state))
    bot_state = case result do
      _ -> if Map.has_key?(state, :bot_state), do: state.bot_state, else: %{}
    end
    {:noreply, %{state | bot_state: bot_state}}
  end

  defp build_user_state_key(team_id, user_id) do
    "#{team_id}-#{user_id}"
  end

  def update_user_state(users_state, users_state_key, old_user_state, new_user_state) do
    very_new_user_state = Map.merge(old_user_state, new_user_state)
    Map.update(users_state, users_state_key, very_new_user_state, fn(_value) -> very_new_user_state end)
  end

  defp contains_key_and_value?(map, key) do
    Map.has_key?(map, key) and map[key] != nil
  end

  defp get_user_state_or_empty(event, state) do
    users_state = users_state_or_empty(state)
    if contains_key_and_value?(event, "team_id") and
       contains_key_and_value?(event, "event") and
       contains_key_and_value?(event["event"], "user") do
      key = "#{event["team_id"]}-#{event["event"]["user"]}"
      if users_state[key] == nil, do: %{}, else: users_state[key]
    else
      %{}
    end
  end

  defp bot_state_or_empty(state) do
    if Map.has_key?(state, :bot_state), do: state.bot_state, else: %{}
  end

  defp users_state_or_empty(state) do
    if Map.has_key?(state, :users_state), do: state.users_state, else: %{}
  end

  defp build_bot_state(state) do
    %{token: state.access_token, bot_id: state.bot_id, team_id: state.team_id}
  end

  defp is_map_empty(map) do
    Enum.count(Map.keys(map)) == 0
  end
end
