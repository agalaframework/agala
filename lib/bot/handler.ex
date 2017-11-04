defmodule Agala.Bot.Handler do
  use GenServer
  require Logger

  @moduledoc """
  Module, represents the bank which gets messages from poller and then syncronosly proceeds them
  """

  @doc false
  def child_spec(bot_params = %{name: name}) do
    %{
      id: "Agala.Bot::Handler##{name}",
      start: {Agala.Bot.Handler, :start_link, [bot_params]}
    }
  end

  defp via_tuple(name) do
    {:global, {:agala, :handler, name}}
  end

  @doc false
  @spec start_link(bot_params :: Agala.BotParams.t) :: GenServer.on_start
  def start_link(bot_params) do
    GenServer.start_link(__MODULE__, bot_params, name: via_tuple(bot_params.name))
  end

  @doc false
  @spec init(bot_params :: Agala.BotParams.t) :: {:ok, Agala.BotParams.t}
  def init(bot_params) do
    Logger.debug(fn -> "Starting handler with params:\n\t#{inspect bot_params}\r" end)
    {:ok, bot_params}
  end

  ### API

  @doc """
  This method is called in order to pass messages from responser to handler.
  This method is asyncronous, so you will not be blocked when calling it.
  All incoming messages will be put in handler's message box and the will be proceeded
  one by one.
  This method will wrap message in `Agala.Conn` struct, and then proceed it with `Agala.Chain`

  """
  @spec handle(message :: any, bot_params :: Agala.BotParams.t) :: :ok
  def handle(message, bot_params) do
    GenServer.cast(
      via_tuple(bot_params.name),
      {:handle, %Agala.Conn{
        request: message,
        request_bot_params: bot_params
      }}
    )
  end

  ### Callbacks

  @doc false
  @spec handle_cast({:handle, conn :: Agala.Conn.t}, bot_params :: Agala.BotParams.t) :: {:noreply, Agala.BotParams.t}
  def handle_cast({:handle, conn}, bot_params = %Agala.BotParams{handler: handler}) do
    conn
    |> handler.call(bot_params)
    |> Agala.response_with
    {:noreply, bot_params}
  end
  def handle_cast(message, state), do: super(message, state)
end
