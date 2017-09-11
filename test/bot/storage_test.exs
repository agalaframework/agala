defmodule Agala.Bot.StorageTest do
  use ExUnit.Case

  alias Agala.{Bot.Storage, BotParams}

  setup do
    bot_params = %BotParams{name: "test"}
    Storage.start_link(bot_params)
    %{bot_params: bot_params}
  end

  test "Storage is initialized" do
    assert is_pid(:global.whereis_name({:agala, :storage, "test"}))
  end

  test "Set and Get are working proper", %{bot_params: bot_params} do
    Agala.Bot.Storage.set(bot_params, :foo, "foo")
    assert "foo" = Agala.Bot.Storage.get(bot_params, :foo)

    Agala.Bot.Storage.set(bot_params, :bar, "bar")
    assert "foo" = Agala.Bot.Storage.get(bot_params, :foo)
    assert "bar" = Agala.Bot.Storage.get(bot_params, :bar)

    Agala.Bot.Storage.set(bot_params, :foo, "bar")
    assert "bar" = Agala.Bot.Storage.get(bot_params, :foo)
    assert "bar" = Agala.Bot.Storage.get(bot_params, :bar)

    assert nil == Agala.Bot.Storage.get(bot_params, :foobar)
  end
end
