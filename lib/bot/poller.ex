defmodule Agala.Bot.Poller do
  use GenServer
  require Logger
  alias Agala.Bot, as: Bot

  @moduledoc """
  Main gen_server module, which is making polling requests to Telegram API
  """

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, [name: Agala.Bot.Poller])
  end

  def init(state) do
    Logger.info "Starting polling server..."
    spawn fn ->
      handle_cast(:start_poll, state)
    end
    {:ok, state}
  end

  def handle_cast(:start_poll, state) do
    do_poll(state)
    {:noreply, state}
  end

  def do_poll(args) do
    offset = Bot.getUpdates(args)
    do_poll(%{timeout: args[:timeout], offset: offset})
  end
end
