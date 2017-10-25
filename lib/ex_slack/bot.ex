defmodule ExSlack.Bot do
  require Logger
  use GenServer

  # Client API

  @doc """
  Starts the the Bot GenServer process.

  `bot_state` is a map with initial values that will be used as the state of the bot process.
  """
  def start_link(token, handler_module, bot_id, bot_state \\ %{}, opts \\ []) do
    {:ok, pid} = GenServer.start_link(__MODULE__, %{
      token: token,
      handler: handler_module,
      bot_id: bot_id,
      process_state: bot_state
    }, opts)
    Process.send_after(pid, :check_slack_events, 1_000)
    {:ok, pid}
  end

  def send_internal_message(pid, message) do
    GenServer.cast(pid, message)
  end

  # Server API

  def init(args) do
    {:ok, socket} = start_socket(args.token)
    {:ok, %{
      token: args.token,
      bot_id: args.bot_id,
      socket: socket,
      handler: args.handler,
      channels: %{}, 
      users: %{},
      process_state: Map.merge(args.process_state, %{token: args.token, bot_id: args.bot_id})
    }}
  end

  def handle_info(:check_slack_events, state) do
    case check_new_slack_events(state.socket) do
      {:ok, %{type: "user_typing"} = msg} ->
        new_channels = process_channels(state.token, state.channels, msg.channel)
        new_users = process_users(state.token, state.users, msg.user)
        {:ok, new_process_state} = state.handler.handle_user_typing(Map.get(new_users, msg.user), state.process_state)
      {:ok, %{type: "message", user: _} = msg}  ->
        IO.inspect msg, label: "Message Received:\n"
        from = case String.first(msg.channel) do
        "D" ->
            new_channels = state.channels
            new_users = process_users(state.token, state.users, msg.user)
            :from_user
        "C" ->
            new_channels = process_channels(state.token, state.channels, msg.channel)
            new_users = process_users(state.token, state.users, msg.user)
            :from_channel
        "G" ->
            new_channels = state.channels
            new_users = process_users(state.token, state.users, msg.user)
            :from_group
        end

        result = case from do
        :from_user -> state.handler.handle_message_from_user(msg, Map.get(new_users, msg.user), state.process_state)
        :from_channel ->
            Logger.info(fn -> "Bod id: #{state.bot_id}, contains: #{String.contains?(msg.text, "<@#{state.bot_id}>")}" end)
            if String.contains?(msg.text, "<@#{state.bot_id}>") do
            state.handler.handle_direct_message_from_channel(msg,
                Map.get(new_channels, msg.channel), Map.get(new_users, msg.user), state.process_state)
            else
            state.handler.handle_message_from_channel(msg,
                Map.get(new_channels, msg.channel), Map.get(new_users, msg.user), state.process_state)
            end
        _ ->
            Logger.info("Not handling message [#{msg.text}]"
            {:ok, state.process_state}
        end

        new_process_state = result |> process_result_from_handler(msg.channel, state)
      {:ok, %{type: "message", bot_id: _}}  ->
        {new_channels, new_users, new_process_state} = same_state(state)
        Logger.info "Message from bot received"
      :reconnect ->
        {new_channels, new_users, new_process_state} = same_state(state)
        Process.send(self(), :socket_reconnect, [])
      _ ->
        {new_channels, new_users, new_process_state} = same_state(state)
        Logger.info "Other message received"
    end
    Process.send_after(self(), :check_slack_events, 1_000)
    {:noreply, %{state | channels: new_channels, users: new_users, process_state: new_process_state}}
  end

  def handle_info(:socket_reconnect, state) do
    Logger.info "Socket reconnect..."
    {:ok, socket} = start_socket(state.token)
    {:noreply, %{state | socket: socket}}
  end

  def handle_info(message, state) do
    new_process_state = state.handler.handle_internal_message(message, state.process_state)
    |> process_result_from_handler(nil, state)
    {:noreply, %{state | process_state: new_process_state}}
  end

  def handle_cast(message, state) do
    new_process_state = state.handler.handle_internal_message(message, state.process_state)
    |> process_result_from_handler(nil, state)
    {:noreply, %{state | process_state: new_process_state}}
  end

  # Utils

  defp process_result_from_handler(result, channel_id, state) do
    case result do
      {:ok, new_state} ->
        new_state
      {:noreply, new_state} ->
        new_state
      {:reply, text, new_state} ->
        if channel_id do
          ExSlack.Methods.Chat.post_message(state.token, channel_id, text)
        end
        new_state
      {:reply_user, {user_slack_id, text}, new_state} ->
        {:ok, new_channel} = ExSlack.Methods.Im.open(state.token, user_slack_id)
        ExSlack.Methods.Chat.post_message(state.token, new_channel.id, text)
        new_state
      {:reply_channel, {channel_slack_id, text}, new_state} ->
        ExSlack.Methods.Chat.post_message(state.token, channel_slack_id, text)
        new_state
      {:replynsend, {text, message}, new_state} ->
        if channel_id do
          ExSlack.Methods.Chat.post_message(state.token, channel_id, text)
        end
        Process.send(self(), message, [])
        new_state
    end
  end

  defp same_state(state) do
    {state.channels, state.users, state.process_state}
  end

  # TODO: Maybe create a Cache object to hold channels and users?
  defp process_channels(token, channels, channel_id) do
    if Map.has_key?(channels, channel_id) do
      channels
    else
      merge_new_channel(channels, ExSlack.Methods.Channels.info(token, channel_id))
    end
  end

  defp merge_new_channel(channels, {:ok, response}) do
    Map.put_new(channels, response.channel.id, response.channel)
  end

  defp merge_new_channel(channels, _), do: channels

  defp process_users(token, users, user_id) do
    if Map.has_key?(users, user_id) do
      users
    else
      merge_new_user(users, ExSlack.Methods.Users.info(token, user_id))
    end
  end

  defp merge_new_user(users, {:ok, response}) do
    Map.put_new(users, response.user.id, response.user)
  end

  defp merge_new_user(users, _), do: users

  defp check_new_slack_events(socket) do
    case socket |> Socket.Web.recv! do
    {:text, msg} ->
      Logger.info "Slack Event: message"
      Poison.Parser.parse(msg, keys: :atoms)
    {:ping, _} ->
      Logger.info "Slack Event: ping"
      {:ok, :ping}
    {:close, :abnormal, msg} ->
      IO.inspect msg, label: "Slack Event: "
      :reconnect
    end
  end

  defp start_socket(token) do
    case ExSlack.RtmApi.connect(token) do
      {:ok, body} ->
        {domain, path} = extract_domain_path(body.url)
        socket = Socket.Web.connect! domain, secure: true, path: path
        {:text, msg} = socket |> Socket.Web.recv!
        case Poison.Parser.parse(msg, keys: :atoms) do
        {:ok, %{type: "hello"}} -> {:ok, socket}
        _ -> {:error, "No hello message from Slack WebSocket #{path}"}
        end
      error -> error
    end
  end

  defp extract_domain_path(socket_url) do
    uri = String.slice(socket_url, 6..-1)
    domain = String.slice(uri, 0..(elem(:binary.match(uri, "/"), 0) - 1))
    path = String.slice(uri, elem(:binary.match(uri, "/"), 0)..-1)
    {domain, path}
   end
end