defmodule Agala.Bot.Responser do
  @callback response(conn :: Agala.Conn.t, Agala.BotParams.t) :: any

  use GenServer
  require Logger

  @moduledoc """
  Module, represents the bank which gets messages from poller and then syncronosly proceeds them
  """

  defp via_tuple(name) do
    {:via, Registry, {Agala.Registry, {:responser, name}}}
  end

  @spec start_link(bot_params :: Agala.BotParams.t) :: GenServer.on_start
  def start_link(bot_params) do
    GenServer.start_link(__MODULE__, bot_params, name: via_tuple(bot_params.name))
  end

  @spec init(bot_params :: Agala.BotParams.t) :: {:ok, Agala.BotParams.t}
  def init(bot_params) do
    Logger.debug("Starting responser with params:\n\t#{inspect bot_params}\r")
    bot_params.provider.init(bot_params, :responser)
  end

  ### API

  def cast_to_handle(conn = %Agala.Conn{responser_name: name, halted: halted}) do
    case halted do
      true -> :ok
      _ -> GenServer.cast(via_tuple(name), {:send_conn, conn})
    end
  end

  ### Callbacks

  @spec handle_cast({:send_conn, conn :: Agala.Conn.t}, bot_params :: Agala.BotParams.t) :: {:noreply, Agala.BotParams.t}
  def handle_cast({:send_conn, conn}, bot_params = %Agala.BotParams{}) do
    bot_params.provider.response(conn, bot_params)
    {:noreply, bot_params}
  end
  def handle_cast(_, state), do: {:noreply, state}
end
