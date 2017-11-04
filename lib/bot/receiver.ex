defmodule Agala.Bot.Receiver do
  @type message :: any
  @moduledoc """
  You can use this behaviour for implementing your own **provider**.

  This receiver has simple generic idea:

  * In loop, it's geting new messages via `get_updates/2` callback
  * Then, these messages are sent into handler one after one.

  So, you actually can `use Agala.Bot.Receiver`, and implement only one method -
  `get_updates/2`, which will get new messages.

  This callback will be called by framework itself, but in order to push messages into `Agala.Bot.Handler`
  you should call `notify_with/1` lambda, that will come as first argument to your `get_updates/2` function.

  ### Example
      # Simple random numbers generator
      defmodule Random.Receiver do
        use Agala.Bot.Receiver

        def get_updates(notify_with, _bot_params) do
          notify_with(:rand.uniform)
        end
      end
  """

  @doc """
  TODO: Docs
  """
  @callback get_updates(notify_with :: (message -> :ok), bot_params :: Agala.BotParams.t) :: Agala.BotParams.t
  defmacro __using__(_) do
    quote location: :keep do
      use GenServer
      require Logger
      @behaviour Agala.Bot.Receiver

      defp via_tuple(name) do
        {:global, {:agala, :receiver, name}}
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
        # this callback will be call to asyncronosly push messages to handler
        notify_with = fn message ->
          Agala.Bot.Handler.handle(message, bot_params)
        end
        new_params = get_updates(notify_with, bot_params)
        case get_in(new_params, ([:common, :restart])) do
          true -> {:stop, :normal, new_params}
          _ -> {:noreply, new_params}
        end
      end
      def handle_info(_, state), do: {:noreply, state}
    end
  end
end
