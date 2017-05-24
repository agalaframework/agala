defmodule Agala.Response do
  defstruct [
    name: nil,
    method: :noaction,
    payload: %{},
    opts: []
  ]

  @type t :: %Agala.Response{
    name: atom,
    method: :noaction | String.t,
    payload: %{},
    opts: Keyword.t
  }
end
