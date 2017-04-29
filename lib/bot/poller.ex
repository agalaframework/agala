defmodule Agala.Bot.Poller do
  use GenServer
  require Logger

  @moduledoc """
  Main gen_server module, which is making polling requests to Telegram API
  """

  @spec start_link(poller_params :: Agala.Bot.PollerParams.t) :: GenServer.on_start
  def start_link(poller_params) do
    GenServer.start_link(__MODULE__, poller_params, [name: Agala.Bot.Poller])
  end

  @spec init(poller_params :: Agala.Bot.PollerParams.t) :: {:ok, Agala.Bot.PollerParams.t}
  def init(poller_params) do
    Logger.info("String poller with params:\n\t#{inspect poller_params}")
    Process.send(self(), :loop, [])
    {:ok, poller_params}
  end

  @spec handle_info(:loop, poller_params :: Agala.Bot.PollerParams.t) :: {:noreply, Agala.Bot.PollerParams.t}
  def handle_info(:loop, poller_params) do
    Process.send(self(), :loop, [])
    {:noreply, Agala.Bot.get_updates(poller_params)}
  end
  def handle_info(_, state), do: {:noreply, state}
end
