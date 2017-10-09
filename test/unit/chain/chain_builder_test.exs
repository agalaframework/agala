defmodule Foo do
  import Agala.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    %{conn | request: :foo}
  end
end

defmodule Bar do
  use Agala.Chain.Builder

  chain :bar
  chain :foobar
  chain Foo

  def bar(conn, _opts) do
    IO.inspect "Calling BAR"
    IO.inspect conn
    %{conn | response: :bar}
  end

  def foobar(conn, _opts) do
    IO.inspect "Calling FOOBAR. Halting..."
    IO.inspect conn
    conn
    |> halt()
  end
end

defmodule ChainBuilderTest do
  use ExUnit.Case

  test "Simple chain" do
    assert %Agala.Conn{request: :foo} == Foo.call(%Agala.Conn{}, [])
  end
end
