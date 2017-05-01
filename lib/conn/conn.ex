defmodule Agala.Conn do
  defstruct [:bot_params, :request, :response]

  @type t :: %Agala.Conn{
    bot_params: Agala.BotParams.t,
    request: Map.t,
    response: Agala.Response.t
  }
end
