defmodule Agala.Bot.Common.Poller do
  @type message :: any
  @moduledoc """
  You can use this behaviour for implementing your own **Agala.Bot.Poller**.

  This poller has simple generic idea:

  * In loop, it's geting new messages via `get_updates/2` callback
  * Then, these messages are sent into chain one after one.

  So, you actually can `use Agala.Bot.Common.Poller`, and implement only one method -
  `get_updates/2`, which will get new messages.

  ### Example
      # Simple random numbers generator
      defmodule Random.Poller do
        use Agala.Bot.Common.Poller

        def get_updates(_opts) do
          [:rand.uniform]
        end
      end
  """

  @doc """
  TODO: Docs
  """
  @callback get_updates(params :: Agala.BotParams.t) :: Agala.BotParams.t

  defmacro __using__(_) do
    quote location: :keep do
      use GenServer
      require Logger
      @behaviour Agala.Bot.Poller

      @spec start_link(opts :: Keyword.t()) :: GenServer.on_start
      def start_link(opts) do
        bot = Keyword.get(opts, :bot)
        bot_params = %Agala.BotParams{
          otp_app: Keyword.get(opts, :otp_app),
          bot: bot,
          provider: Keyword.get(opts, :provider),
          chain: Keyword.get(opts, :chain),
          provider_params: Keyword.get(opts, :provider_params)
        }
        GenServer.start_link(__MODULE__, bot_params, name: Module.concat(bot, Poller))
      end

      @spec init(bot_params :: Agala.BotParams.t) :: {:ok, Agala.BotParams.t}
      def init(bot_params) do
        Process.register(self(), :"#Agala.Bot.Receiver<#{bot_params.name}>")
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
