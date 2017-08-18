defmodule Agala.Provider.Test do
  use ExUnit.Case

  defmodule Foo do
    use Agala.Provider
  end

  defmodule Bar do
    use Agala.Provider

    def get_receiver() do
      Foo
    end

    def get_responser() do
      Bazz
    end
  end

  test "Using without override" do
    assert Agala.Provider.Test.Foo.Receiver = Foo.get_receiver
    assert Agala.Provider.Test.Foo.Responser = Foo.get_responser
  end

  test "Using with override" do
    assert Foo = Bar.get_receiver
    assert Bazz = Bar.get_responser
  end
end
