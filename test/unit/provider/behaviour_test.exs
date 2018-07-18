defmodule Agala.Provider.Test do
  use ExUnit.Case

  defmodule Foo do
    use Agala.Provider
  end

  defmodule Bar do
    use Agala.Provider

    def get_bot(:poller) do
      Poller
    end

    def get_bot(:handler) do
      Handler
    end

    def get_bot(:plug) do
      Plug
    end
  end

  test "Using without override" do
    assert Agala.Provider.Test.Foo.Poller = Foo.get_bot(:poller)
    assert Agala.Provider.Test.Foo.Handler = Foo.get_bot(:handler)
    assert Agala.Provider.Test.Foo.Plug = Foo.get_bot(:plug)
  end

  test "Using with override" do
    assert Poller = Bar.get_bot(:poller)
    assert Handler = Bar.get_bot(:handler)
    assert Plug = Bar.get_bot(:plug)
  end
end
