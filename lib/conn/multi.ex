defmodule Agala.Conn.Multi do
  @moduledoc """
  This module represents a set of macros, that can be used to performed multiple
  operation inside one `Agala.Conn` instance.

  ### The problem

  Sometimes you need to perform several actions inside one `batch`.
  For example send multiple messages, or delete previous message and send new one.
  You can do this inside handler inside handling one `Agala.Conn`.
  """
  defstruct [conns: []]

  defmacro multi(do: block) do
    quote do
      {:ok, var!(buffer, Agala.Conn.Multi)} = start_buffer([])
      unquote block
      result = render(var!(buffer, Agala.Conn.Multi))
      :ok = stop_buffer(var!(buffer, Agala.Conn.Multi))
      result
    end
  end

  @doc false
  def start_buffer(state), do: Agent.start_link(fn -> state end)
  @doc false
  def stop_buffer(buff), do: Agent.stop(buff)
  @doc false
  def put_buffer(buff, content), do: Agent.update(buff, &[content | &1])
  @doc false
  def render(buff) do
    %Agala.Conn{multi: %Agala.Conn.Multi{conns: Enum.reverse(Agent.get(buff, &(&1)))}}
  end

  defmacro add(conn_structure) do
    quote do
      case unquote(conn_structure) do
        conn = %Agala.Conn{} ->
          put_buffer(var!(buffer, Agala.Conn.Multi), conn)
        bad_add ->
          raise(
            ArgumentError,
            "Expected to add %Agala.Conn{} instance, but got #{inspect bad_add}"
          )
      end
    end
  end
end
