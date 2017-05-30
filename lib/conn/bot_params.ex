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

  @behaviour Access
  def fetch(bot_params, key) do
    Map.fetch(bot_params, key)
  end

  def get(structure, key, default \\ nil) do
    Map.get(structure, key, default)
  end

  def get_and_update(term, key, list) do
    Map.get_and_update(term, key, list)
  end

  def pop(term, key) do
    {get(term, key), term}
  end
end
