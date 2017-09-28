defmodule ExSlackTest do
  use ExUnit.Case
  doctest ExSlack

  test "greets the world" do
    assert ExSlack.hello() == :world
  end
end
