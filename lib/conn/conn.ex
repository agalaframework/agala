defmodule Agala.Conn do
  defstruct [:bot_params, :request, :response]

  @type t :: %Agala.Conn{
    bot_params: Agala.Conn.BotParams.t,
    request: Map.t,
    response: Agala.Conn.Response.t
  }
end
