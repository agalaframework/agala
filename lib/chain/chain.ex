defmodule Agala.Chain do
  @moduledoc """
  The Chain specification.


  There are two kind of Chains: function Chains and module Chains.

  #### Function Chains

  A function Chain is any function that receives a connection and a set of
  options and returns a connection. Its type signature must be:
      (Agala.Conn.t, Agala.Chain.opts) :: Agala.Conn.t

  #### Module Chains

  A module Chain is an extension of the function Chain. It is a module that must
  export:
    * a `call/2` function with the signature defined above
    * an `init/1` function which takes a set of options and initializes it.
  The result returned by `init/1` is passed as second argument to `call/2`. Note
  that `init/1` may be called during compilation and as such it must not return
  pids, ports or values that are not specific to the runtime.
  The API expected by a module Chain is defined as a behaviour by the
  `Agala.Chain` module (this module).
  ## Examples
  Here's an example of a function Chain:
      #TODO
  Here's an example of a module Chain:
      #TODO
  ## The Chain pipeline
  The `Agala.Chain.Builder` module provides conveniences for building Chain
  pipelines.
  """

  @type opts :: binary | tuple | atom | integer | float | [opts] | %{opts => opts}

  @callback init(opts :: opts) :: opts
  @callback call(conn :: Agala.Conn.t, opts) :: Agala.Conn.t
end
