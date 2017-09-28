defmodule ExSlack do
  
  defmacro __using__(_) do
    quote do
      def handle_user_typing(user, state), do: {:ok, state}
      def handle_message_from_user(_message, _user, state), do: {:ok, state}
      def handle_message_from_channel(_message, _channel, _user, state), do: {:ok, state}
      def handle_direct_message_from_channel(_message, _channel, _user, state), do: {:ok, state}
      def handle_internal_message(message, state), do: {:ok, state}

      defoverridable [
        handle_user_typing: 2,
        handle_message_from_user: 3,
        handle_message_from_channel: 4,
        handle_direct_message_from_channel: 4,
        handle_internal_message: 2
      ]
    end
  end
end