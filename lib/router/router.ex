defmodule Agala.Router do
  @moduledoc ~S"""
  Specification of the router
  """
  @type t :: module

  @type message :: any

  @callback route(message) :: any
end
