defmodule ExSlackEventsApiBot do
  defmacro __using__(_) do
    quote do
      def handle_event(event, state), do: {:ok, state}
      def handle_interactive_message(payload, state), do: {:ok, state}

      defoverridable [
        handle_event: 2,
        handle_interactive_message: 2
      ]
    end
  end
end