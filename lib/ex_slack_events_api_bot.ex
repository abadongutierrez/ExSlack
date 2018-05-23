defmodule ExSlackEventsApiBot do
  defmacro __using__(_) do
    quote do
      def handle_event(event, user_state, bot_state), do: :ok
      def handle_interactive_message(payload, bot_state), do: :ok

      defoverridable [
        handle_event: 3,
        handle_interactive_message: 2
      ]
    end
  end
end