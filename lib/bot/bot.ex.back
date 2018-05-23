defmodule Agala.Bot do
  @moduledoc """
  This module represents main Bot supervisor.

  **Bot** is a complex module, that can retreive information, handle it and send either to recepient
  or to another Bot module.

  Defining new **Bot** requires only `name`, `provider` and `handler`.

  When the **Bot** is starting it will automaticly make supervision tree for next modules:

  * `Agala.Bot.Receiver` - module which gets new data from the recepient defined as a `provider`
  * `Agala.Bot.Handler` - module which is handling messages, that are incoming to the `bot`
  * `Agala.Bot.Responser` - module, that converts your application responses into form,
    acceptable by the recepient
  * `Agala.Bot.Storage` [**OPTIONALY**] - module with *Storage* behaviour, that helps with
    keeping cross-crashing data for providers

  ### Starting your bot

  You can start as many bots as you want. They should be differ from each other only by name.
  Thus, they can have similar provider, handler and whatever you want. To specify bot instance,
  use `Agala.BotParams` - they should be passed as an argument to start new bot.

  ### Example

      # Starting 2 bots with different providers:
      Supervisor.start_link([
        {Agala.Bot, %{name: "telegram", provider: Agala.Provider.Telegram, handler: ...}},
        {Agala.Bot, %{name: "vk", provider: Agala.Provider.Vk, handler: ...}},
      ])
  """
  use Supervisor

  @doc false
  def child_spec(bot_params = %{name: name}) do
    %{
      id: :"#Agala.Bot<#{name}>",
      start: {Agala.Bot, :start_link, [bot_params]},
      type: :supervisor
    }
  end

  defp via_tuple(name) do
    {:global, {:agala, :bot, name}}
  end

  @doc false
  def start_link(bot_params) do
    Supervisor.start_link(__MODULE__, bot_params, name: via_tuple(bot_params.name))
  end

  @doc false
  def init(bot_params = %{
    storage: storage,
    provider: provider
  }) do
    Process.register(self(), :"#Agala.Bot<#{bot_params.name}>")
    Code.ensure_loaded(storage)
    case function_exported?(storage, :child_spec, 1) do
      true -> [{storage, bot_params}]
      false -> []
    end ++ [
      {provider.get_responser(), bot_params},
      {Agala.Bot.Handler, bot_params},
      {provider.get_receiver(), bot_params},
    ]
    |> Supervisor.init(strategy: :one_for_one)
  end
end
