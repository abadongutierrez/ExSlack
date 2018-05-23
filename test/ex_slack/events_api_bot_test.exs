defmodule ExSlack.EventsApiBotTest do
  use ExUnit.Case

  alias ExSlack.EventsApiBot

  test "state should return with new user state added" do
    state = %{
      handler: ExSlack.TestModule,
      access_token: "123456",
      bot_id: "12345",
      team_id: "T12345",
      users_state: %{},
      bot_state: %{}
    }
    event = %{
      "team_id" => "T666",
      "event" => %{
        "text" => "Some message!",
        "user" => "U123",
      }
    }
    {:noreply, new_state} = EventsApiBot.handle_cast({:event, event}, state)
    key = "#{event["team_id"]}-#{event["event"]["user"]}"
    assert Map.has_key?(new_state, :users_state)
    assert Map.has_key?(new_state.users_state, key)
    assert new_state.users_state[key] == elem(ExSlack.TestModule.handle_event(nil, nil, nil), 1)
  end

  test "handle_cast should return with new user state merged" do
    team_id = "T666"
    user_id = "U123"
    key = "#{team_id}-#{user_id}"
    state = %{
      handler: ExSlack.TestModule,
      access_token: "123456",
      bot_id: "12345",
      team_id: "T12345",
      users_state: %{
        "#{key}" => %{
          anotherProp: 345
        }
      },
      bot_state: %{}
    }
    event = %{
      "team_id" => team_id,
      "event" => %{
        "text" => "Some message!",
        "user" => user_id,
      }
    }
    {:noreply, new_state} = EventsApiBot.handle_cast({:event, event}, state)

    assert new_state.users_state[key].anotherProp == 345
    assert new_state.users_state[key].prop1 == 1
    assert new_state.users_state[key].prop2 == 2
  end

  test "update_user_state should update the users state map" do
    key = "T666-U123"
    users_state = %{
      "#{key}" => %{
        anotherProp: 345
      },
      "1234" => %{
        anotherProp: 123
      }
    }
    new_users_state = EventsApiBot.update_user_state(users_state, key, users_state[key], %{prop1: 1, prop2: 2})
    assert new_users_state[key].anotherProp == 345
    assert new_users_state[key].prop1 == 1
    assert new_users_state[key].prop2 == 2
    assert new_users_state["1234"].anotherProp == 123
  end
end

defmodule ExSlack.TestModule do
  def handle_event(event, user_state, bot_state) do
    {:user_state, %{prop1: 1, prop2: 2}}
  end
end
