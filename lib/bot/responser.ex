defmodule Agala.Bot.PollHandler do
  use GenServer
  require Logger

  @moduledoc """
  Module, represents the bank which gets messages from poller and the syncronosly proceeds them
  """

  def via_tuple(name) do
    {:via, Registry, {Agala.Registry, {:responser, name}}
  end

  @spec start_link(bot_params :: Agala.BotParams.t) :: GenServer.on_start
  def start_link(bot_params) do
    GenServer.start_link(__MODULE__, bot_params, name: via_tuple(bot_params.name))
  end

  @spec init(bot_params :: Agala.BotParams.t) :: {:ok, Agala.BotParams.t}
  def init(bot_params) do
    Logger.info("Starting poll handler with params:\n\t#{inspect poller_params}\r")
    {:ok, bot_params}
  end

  ### API

  def cast_to_handle(message, bot_params) do
    GenServer.cast(
      via_tuple(bot_params.name),
      {:polled_message, %Agala.Conn{
        request: message
      }}
    )
  end

  ### Callbacks

  @spec handle_cast({:polled_message, conn}, bot_params :: Agala.BotParams.t) :: {:noreply, Agala.BotParams.t}
  def handle_cast({:polled_message, conn}, bot_params = %Agala.BotParams{handler: handler}) do
    handler.handle(conn)
    |> Agala.response_with
    {:noreply, bot_params}
  end
  def handle_cast(_, state), do: {:noreply, state}
end
