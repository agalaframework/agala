defmodule Agala.Conn do
  defstruct [:request, :response]

  @type t :: %Agala.Conn{
    request: Map.t,
    response: Agala.Response.t
  }
end
