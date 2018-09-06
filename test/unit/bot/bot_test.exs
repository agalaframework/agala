defmodule Agala.Bot.StorageTest do
  use ExUnit.Case
  alias Agala.Bot
  alias Agala.BotParams

  setup do
    %{bot_params: %BotParams{name: "test"}}
  end

  test "Bot child-spec is proper", %{bot_params: bot_params} do
    assert %{id: :"#Agala.Bot<test>", type: :supervisor} = Bot.child_spec(bot_params)
  end
end
