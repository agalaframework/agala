defmodule Agala.Conn.Multi do
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

  def start_buffer(state), do: Agent.start_link(fn -> state end)
  def stop_buffer(buff), do: Agent.stop(buff)
  def put_buffer(buff, content), do: Agent.update(buff, &[content | &1])

  def render(buff) do
    %Agala.Conn{multi: %Agala.Conn.Multi{conns: Agent.get(buff, &(&1))}}
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
