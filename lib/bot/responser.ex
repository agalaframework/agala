defmodule Agala.Bot.Responser do
  require Logger
  @moduledoc """
  Behaviour, represents the bank which gets Agala.Conn from Chain
  and then syncronosly proceeds them to response
  """

  @callback response(conn :: Agala.Conn.t, bot_params :: Agala.BotParams.t) :: any

  defp via_tuple(name) do
    {:global, {:agala, :responser, name}}
  end

  defmacro __using__(_) do
    quote location: :keep do
      use GenServer
      require Logger

      defp via_tuple(name) do
        {:global, {:agala, :responser, name}}
      end

      @spec start_link(bot_params :: Agala.BotParams.t) :: GenServer.on_start
      def start_link(bot_params) do
        GenServer.start_link(__MODULE__, bot_params, name: via_tuple(bot_params.name))
      end

      @spec init(bot_params :: Agala.BotParams.t) :: {:ok, Agala.BotParams.t}
      def init(bot_params) do
        Process.register(self(), :"#Agala.Bot.Responser<#{bot_params.name}>")
        Logger.debug("Starting responser with params:\n\t#{inspect bot_params}\r")
        bot_params.provider.init(bot_params, :responser)
      end

      ### Callbacks

      @spec handle_cast({:send_conn, conn :: Agala.Conn.t}, bot_params :: Agala.BotParams.t) :: {:noreply, Agala.BotParams.t}
      def handle_cast({:response, conn}, bot_params = %Agala.BotParams{}) do
        response = bot_params.provider.get_responser().response(conn, bot_params)
        case conn.fallback do
          lambda when is_function(lambda) -> lambda.(Map.put(conn, :fallback, response))
          _ -> :ok
        end
        {:noreply, bot_params}
      end
      def handle_cast(_, state), do: {:noreply, state}
    end
  end

  @doc """
  This method can be used to send `Agala.Conn`,
  prepared by `Agala.Chain`, to appropriate provider responer,
  which implements `Agala.Reponser` behaviour.
  """
  def response(%Agala.Conn{multi: %Agala.Conn.Multi{conns: conns}}) do
    Enum.each(conns, &response/1)
  end
  def response(%Agala.Conn{responser_name: nil}) do
    Logger.warn("Responser's name was not specified for the connection. Please, check your chain.")
  end
  def response(%Agala.Conn{halted: true}), do: :ok
  def response(conn = %Agala.Conn{responser_name: name}) do
    GenServer.cast(via_tuple(name), {:response, conn})
  end
end
