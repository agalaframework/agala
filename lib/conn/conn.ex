defmodule Agala.Conn do
  defstruct [:bot_params, :request, :response]

  @type t :: %Agala.Conn{
    request: Map.t,
    response: Agala.Response.t
  }
end
