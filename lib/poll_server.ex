defmodule Agala.Bot.PollServer do
  use GenServer
  require Logger

  @moduledoc """
  Main gen_server module, which is making polling requests to Telegram API
  """

  defp via_tuple(name) do
    {:via, Registry, {Agala.Registry, {:poll, name}}
  end

  @spec start_link(bot_params :: Agala.BotParams.t) :: GenServer.on_start
  def start_link(bot_params) do
    GenServer.start_link(__MODULE__, bot_params, name: via_tuple(bot_params.name))
  end

  @spec init(bot_params :: Agala.BotParams.t) :: {:ok, Agala.BotParams.t}
  def init(bot_params) do
    Logger.info("Starting poller with params:\n\t#{inspect poller_params}\r")
    Process.send(self(), :loop, [])
    {:ok, bot_params}
  end

  @spec handle_info(:loop, bot_params :: Agala.BotParams.t) :: {:noreply, Agala.BotParams.t}
  def handle_info(:loop, bot_params) do
    Process.send(self(), :loop, [])
    {:noreply, bot_params.poller.get_updates(bot_params)}
  end
  def handle_info(_, state), do: {:noreply, state}
end
