defmodule Chain.LoopbackTest do
  use ExUnit.Case
  alias Agala.Chain.Loopback

  describe "Agala.Chain.Loopback :" do
    test ": init" do
      assert %{opts: :opts} == Loopback.init(%{opts: :opts})
    end

    test ": call" do
      assert %Agala.Conn{responser_name: "test"} =
        Loopback.call(%Agala.Conn{request_bot_params: %{name: "test"}}, [])
    end
  end
end
