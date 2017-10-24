defmodule Agala.Bot.StorageTest do
  use ExUnit.Case

  alias Agala.Bot.Storage.Local, as: Storage
  alias Agala.BotParams

  setup do
    bot_params = %BotParams{name: "test"}
    Storage.start_link(bot_params)
    %{bot_params: bot_params}
  end

  test "Storage is initialized" do
    assert is_pid(:global.whereis_name({:agala, :storage, "test"}))
  end

  test "Set and Get are working proper", %{bot_params: bot_params} do
    Storage.set(bot_params, :foo, "foo")
    assert "foo" = Storage.get(bot_params, :foo)

    Storage.set(bot_params, :bar, "bar")
    assert "foo" = Storage.get(bot_params, :foo)
    assert "bar" = Storage.get(bot_params, :bar)

    Storage.set(bot_params, :foo, "bar")
    assert "bar" = Storage.get(bot_params, :foo)
    assert "bar" = Storage.get(bot_params, :bar)

    assert nil == Storage.get(bot_params, :foobar)
  end
end
