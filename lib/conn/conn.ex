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

  defstruct [:request, :response, :halted, :request_bot_params, :responser_name]

  @type t :: %Agala.Conn{
    request: Map.t,
    response: Map.t,
    halted: boolean,
    request_bot_params: Agala.BotParams.t,
    responser_name: String.t | Atom
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
