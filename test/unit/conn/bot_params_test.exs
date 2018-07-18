defmodule Agala.BotParamsTest do
  use ExUnit.Case

  setup do
    %{bot_params: %Agala.BotParams{
      private: %{},
      bot: Test,
      provider: FooProvider,
      chain: FooHandler,
      provider_params: nil
    }}
    end

  describe "Agala.BotParams :" do
    test ": access is working proper", %{bot_params: bot_params} do
      assert {:ok, %{}} = Access.fetch(bot_params, :private)
      assert {:ok, FooProvider} = Access.fetch(bot_params, :provider)
      assert {:ok, nil} = Access.fetch(bot_params, :provider_params)

      assert FooHandler = Access.get(bot_params, :chain)
      assert nil == Access.get(bot_params, :foo)

      assert {Test, %{bot: Shmest}} = Access.get_and_update(bot_params, :bot, fn _ -> {Test, Shmest} end)

      assert {Test, %{bot: Test}} = Access.pop(bot_params, :bot)
    end
  end
end
