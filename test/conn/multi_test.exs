defmodule Agala.Conn.MultiTest do
  use ExUnit.Case
  import Agala.Conn.Multi

  def good_multi do
    multi do
      add %Agala.Conn{}
      add %Agala.Conn{}
      add %Agala.Conn{}
    end
  end

  def still_good_multi do
    multi do
      :nothing
    end
  end

  def wrong_add do
    multi do
      add %Agala.Conn{}
      add %Agala.Conn{}
      add :wrong_add
    end
  end

  test "test good multi" do
    assert %Agala.Conn.Multi{} = Agala.Conn.MultiTest.good_multi()
    assert %Agala.Conn.Multi{} = Agala.Conn.MultiTest.still_good_multi()
  end

  test "test wrong" do
    assert_raise ArgumentError, fn ->
      Agala.Conn.MultiTest.wrong_add()
    end
  end
end
