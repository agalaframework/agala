defmodule Agala.Bundle.Config do
  defstruct [
    module: nil,
    provider: nil,
    type: nil
  ]

  @type t :: [
    module: atom(),
    provider: atom(),
    type: :provider | :plug
  ]
end
