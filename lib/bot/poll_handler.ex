defmodule Agala.Bot.PollHandler do
  use GenServer
  require Logger

  @moduledoc """
  Module, represents the bank which gets messages from poller and then syncronosly proceeds them
  """

  defp via_tuple(name) do
    {:via, Registry, {Agala.Registry, {:poll_handler, name}}}
  end

  @spec start_link(bot_params :: Agala.BotParams.t) :: GenServer.on_start
  def start_link(bot_params) do
    GenServer.start_link(__MODULE__, bot_params, name: via_tuple(bot_params.name))
  end

  @spec init(bot_params :: Agala.BotParams.t) :: {:ok, Agala.BotParams.t}
  def init(bot_params) do
    Logger.info("Starting poll handler with params:\n\t#{inspect bot_params}\r")
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

  @spec handle_cast({:polled_message, conn :: Agala.Conn.t}, bot_params :: Agala.BotParams.t) :: {:noreply, Agala.BotParams.t}
  def handle_cast({:polled_message, conn}, bot_params = %Agala.BotParams{handler: handler}) do
    handler.handle(conn, bot_params)
    |> Agala.response_with
    {:noreply, bot_params}
  end
  def handle_cast(_, state), do: {:noreply, state}
end
