defmodule Agala.Conn.MultiTest do
  use ExUnit.Case
  import Agala.Conn.Multi

  def good_multi do
    multi do
      add(%Agala.Conn{})
      add(%Agala.Conn{})
      add(%Agala.Conn{})
    end
  end

  def still_good_multi do
    multi do
      :nothing
    end
  end

  def wrong_add do
    multi do
      add(%Agala.Conn{})
      add(%Agala.Conn{})
      add(:wrong_add)
    end
  end

  def order_multi do
    multi do
      add(%Agala.Conn{assigns: %{index: 1}})
      add(%Agala.Conn{assigns: %{index: 2}})
    end
  end

  test "test good multi" do
    assert %Agala.Conn{multi: %Agala.Conn.Multi{}} = Agala.Conn.MultiTest.good_multi()
    assert %Agala.Conn{multi: %Agala.Conn.Multi{}} = Agala.Conn.MultiTest.still_good_multi()
  end

  test "test wrong" do
    assert_raise ArgumentError, fn ->
      Agala.Conn.MultiTest.wrong_add()
    end
  end

  test "Multi execute conns in right order" do
    assert %Agala.Conn{
             multi: %Agala.Conn.Multi{
               conns: [%Agala.Conn{assigns: %{index: 1}}, %Agala.Conn{assigns: %{index: 2}}]
             }
           } = Agala.Conn.MultiTest.order_multi()
  end
end
