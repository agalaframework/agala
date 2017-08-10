defmodule Agala.Conn do
  @moduledoc """
  The Agala connection.

  This module defines a `Agala.Conn` struct. This struct contains
  both request and response data.

  ## Request fields


  These fields contain request information:

    * `request` - request data structure. It's internal structure depends
    on provider type.
  """

  defstruct [:request, :response, :halted]

  @type t :: %Agala.Conn{
    request: Map.t,
    response: Agala.Response.t,
    halted: boolean
  }


  @doc """
  Halts the Agala.Chain pipeline by preventing further plugs downstream from being
  invoked. See the docs for `Agala.Chain.Builder` for more information on halting a
  plug pipeline.
  """
  @spec halt(t) :: t
  def halt(%Agala.Conn{} = conn) do
    %{conn | halted: true}
  end
end
