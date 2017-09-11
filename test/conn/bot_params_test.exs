defmodule Agala.BotParamsTest do
  use ExUnit.Case

  alias Agala.BotParams

  setup do
    %{bot_params: %Agala.BotParams{
      private: %{},
      name: "test",
      provider: FooProvider,
      handler: FooHandler,
      provider_params: nil
    }}
    end

  describe "Agala.BotParams :" do
    test ": access is working proper", %{bot_params: bot_params} do
      assert {:ok, %{}} = Access.fetch(bot_params, :private)
      assert {:ok, FooProvider} = Access.fetch(bot_params, :provider)
      assert {:ok, nil} = Access.fetch(bot_params, :provider_params)

      assert FooHandler = Access.get(bot_params, :handler)
      assert nil == Access.get(bot_params, :foo)

      assert {"test", %{name: "shmest"}} = Access.get_and_update(bot_params, :name, fn _ -> {"test", "shmest"} end)

      assert {"test", %{name: "test"}} = Access.pop(bot_params, :name)
    end
  end
end
