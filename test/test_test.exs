defmodule TestTest do
  use ExUnit.Case

  setup do
    IO.inspect "First setup"
    {:ok, %{foo: "first"}}
  end

  setup do
    IO.inspect "Second setup"
    {:ok, %{bar: "second"}}
  end

  test "Bot child-spec is proper", %{foo: foo, bar: bar} do
    IO.inspect foo
    IO.inspect bar
    assert 1+2==3
  end
end
