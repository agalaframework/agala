defmodule Agala.Chain.Loopback do
  @moduledoc """
  Loopback automaticly sends response back to the bot, which got the request
  """
  import Agala.Conn

  def init(opts) do
    opts
  end

  @spec call(conn :: Agala.Conn.t, opts :: any) :: Agala.Conn.t
  def call(conn = %Agala.Conn{request_bot_params: %{name: name}}, _opts) do
    send_to(conn, name)
  end
end
