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

        def get_updates(bot_params) do
          {[:rand.uniform], bot_params}
        end
      end
  """

  @doc """
  TODO: Docs
  """
  @callback get_updates(bot_params :: Agala.BotParams.t()) :: {list(), Agala.BotParams.t()}

  @doc """
  This function is called inside `init/1` callback of a `GenServer` in order
  to bootstrap initial params for a bot.
  `:private` and `:common` params can be modified here
  """
  @callback bootstrap(bot_params :: Agala.BotParams.t()) :: {:ok, Agala.BotParams.t()} | {:error, any()}

  defmacro __using__(_) do
    quote location: :keep do
      use GenServer
      require Logger
      @behaviour Agala.Bot.Poller

      def child_spec(opts) do
        %{
          id: Module.concat(opts.bot, Poller),
          start: {__MODULE__, :start_link, [opts]},
          type: :worker
        }
      end

      @spec start_link(opts :: Map.t()) :: GenServer.on_start
      def start_link(opts) do
        bot_params = struct(Agala.BotParams, opts)
        GenServer.start_link(__MODULE__, bot_params, name: Module.concat(bot_params.bot, Poller))
      end

      @spec init(bot_params :: Agala.BotParams.t) :: {:ok, Agala.BotParams.t}
      def init(bot_params) do
        Logger.debug("Starting receiver with params:\n\t#{inspect bot_params}\r")
        Process.send(self(), :loop, [])
        bootstrap(bot_params)
      end

      @spec handle_info(:loop, bot_params :: Agala.BotParams.t) :: {:noreply, Agala.BotParams.t}
      def handle_info(:loop, bot_params) do
        Process.send(self(), :loop, [])
        # this callback will be call to asyncronosly push messages to handler
        {updates, new_bot_params} = get_updates(bot_params)
        updates
        |> Enum.each(fn event ->
          new_bot_params.chain.call(%Agala.Conn{request: event, request_bot_params: new_bot_params}, [])
        end)
        case get_in(new_bot_params, ([:common, :restart])) do
          true -> {:stop, :normal, new_bot_params}
          _ -> {:noreply, new_bot_params}
        end
      end
      def handle_info(_, state), do: {:noreply, state}
    end
  end
end
