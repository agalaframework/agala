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




  defstruct [:request, :response]

  @type t :: %Agala.Conn{
    request: Map.t,
    response: Agala.Response.t
  }
end
