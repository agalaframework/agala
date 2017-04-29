defmodule Agala.Conn do
  defstruct [:poller_params, :request, :response]

  @type t :: %Agala.Conn{
    poller_params: Agala.Conn.PollerParams.t,
    request: Map.t,
    response: Agala.Conn.Response.t
  }
end
