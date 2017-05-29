defmodule Agala.BotParams do

  @type t :: %Agala.BotParams{
    private: %{},
    name: atom,
    provider: atom,
    handler: atom,
    provider_params: %{
      #token: String.t,
      #poll_timeout: integer | :infinity,
      #response_timeout: integer | :infinity
    }
  }
  defstruct [:private, :name, :provider, :handler, :provider_params]
end
