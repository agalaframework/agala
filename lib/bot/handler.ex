defmodule Agala.Bot.Handler do
  use GenServer
  require Logger

  @moduledoc """
  Module, represents the bank which gets messages from poller and then syncronosly proceeds them
  """

  @spec start_link(bot_params :: Agala.BotParams.t) :: GenServer.on_start
  def start_link(bot_params) do
    GenServer.start_link(__MODULE__, bot_params)
  end

  @spec init(bot_params :: Agala.BotParams.t) :: {:ok, Agala.BotParams.t}
  def init(bot_params) do
    Logger.debug(fn -> "Starting handler with params:\n\t#{inspect bot_params}\r" end)
    {:ok, bot_params}
  end

  ### API

  @spec proceed_sync(pid :: pid, message :: any, bot_params :: Agala.BotParams.t) :: term
  def proceed_sync(pid, message, bot_params) do
    GenServer.call(
      pid,
      {:proceed_sync, %Agala.Conn{
        request: message,
        request_bot_params: bot_params
      }}
    )
  end

  ### Callbacks

  @spec handle_call({:proceed_sync, conn :: Agala.Conn.t}, from :: pid, bot_params :: Agala.BotParams.t) :: {:reply, Agala.BotParams.t}
  def handle_call({:polled_message, conn}, _, bot_params = %Agala.BotParams{handler: handler}) do
    conn
    |> handler.call(bot_params)
    |> Agala.response_with
    {:reply, :ok, bot_params}
  end
  def handle_call(request, from, state), do: super(request, from, state)
end
