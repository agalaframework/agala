defmodule Agala.Bot.Receiver do
  @callback get_updates(bot_params :: Agala.BotParams.t) :: Agala.BotParams.t
  @moduledoc """
  TODO
  """
  defmacro __using__(_) do
    quote location: :keep do
      use GenServer
      require Logger
      @behaviour Agala.Bot.Receiver

      defp via_tuple(name) do
        {:via, Registry, {Agala.Registry, {:receiver, name}}}
      end

      @spec start_link(bot_params :: Agala.BotParams.t) :: GenServer.on_start
      def start_link(bot_params) do
        GenServer.start_link(__MODULE__, bot_params, name: via_tuple(bot_params.name))
      end

      @spec init(bot_params :: Agala.BotParams.t) :: {:ok, Agala.BotParams.t}
      def init(bot_params) do
        Logger.debug("Starting receiver with params:\n\t#{inspect bot_params}\r")
        Process.send(self(), :loop, [])
        bot_params.provider.init(bot_params, :receiver)
      end

      @spec handle_info(:loop, bot_params :: Agala.BotParams.t) :: {:noreply, Agala.BotParams.t}
      def handle_info(:loop, bot_params) do
        Process.send(self(), :loop, [])
        new_params = get_updates(bot_params)
        case get_in(new_params, ([:private, :restart])) do
          true -> {:stop, :normal, new_params}
          _ -> {:noreply, new_params}
        end
      end
      def handle_info(_, state), do: {:noreply, state}
    end
  end
end
