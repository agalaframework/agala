defmodule Agala.Bot.Supervisor do
  use Supervisor
  # These default can be filled by some default parameters in the future
  @defaults []

  @doc """
  Retrieves the compile time configuration for the bot.
  """
  @spec compile_config(:poller | :plug | :handler, bot :: Agala.Bot.t(), opts :: Keyword.t()) ::
          {atom, Agala.Provider.t(), Keyword.t()}
  def compile_config(:poller, bot, opts) do
    otp_app = Keyword.fetch!(opts, :otp_app)
    config = Application.get_env(otp_app, bot, [])
    config = Keyword.merge(opts, config)

    # Provider checking section

    provider = opts[:provider] || config[:provider]

    unless provider do
      raise ArgumentError,
            "missing :provider configuration in " <> "config #{inspect(otp_app)}, #{inspect(bot)}"
    end

    unless Code.ensure_compiled?(provider) do
      raise ArgumentError,
            "provider #{inspect(provider)} was not compiled, " <>
              "ensure it is correct and it is included as a project dependency"
    end

    # Handler checking section

    chain = opts[:chain] || config[:chain]

    unless chain do
      raise ArgumentError,
            "missing :chain configuration in " <> "config #{inspect(otp_app)}, #{inspect(bot)}"
    end

    unless Code.ensure_compiled?(chain) do
      raise ArgumentError,
            "chain #{inspect(chain)} was not compiled, " <>
              "ensure it is correct and it is included as a module in the project"
    end

    unless Agala.Chain in Agala.Util.behaviours_list(chain) do
      raise ArgumentError,
            "chain #{inspect(chain)} does not implement Agala.Chain behaviour, " <>
              "ensure it is correct and it is included as a module in the project"
    end

    {otp_app, provider, config}
  end

  @doc """
  Retrieves the runtime configuration for the bot.
  """
  @spec runtime_config(
          mode :: :poller | :plug | :handler,
          type :: :dry_run | :supervisor,
          bot :: Agala.Bot.t(),
          otp_app :: atom(),
          opts :: Keyword.t()
        ) :: {:ok, Keyword.t()} | :ignore
  def runtime_config(:poller, type, bot, otp_app, opts) do
    IO.inspect "Inside runtime config"
    if config = Application.get_env(otp_app, bot, []) do
      config =
        [otp_app: otp_app, bot: bot]
        |> Keyword.merge(@defaults)
        |> Keyword.merge(config)
        |> Enum.into(%{})
        |> Map.merge(opts)

      case bot_init(type, bot, config) do
        {:ok, config} -> {:ok, config}
        :ignore -> :ignore
      end
    else
      raise ArgumentError,
            "configuration for #{inspect(bot)} not specified in #{inspect(otp_app)} environment"
    end
  end

  ### Start section
  @spec start_link(
    mode :: :poller | :plug | :handler,
    bot :: Agala.Bot.t(),
    otp_app :: atom(),
    provider :: Agala.Provider.t(),
    opts :: Keyword.t()
  ) :: Supervisor.on_start()
  def start_link(:plug, bot, _, _, _) do
    raise RuntimeError,
      "Plugs should not be started as supervisors. Check out your #{inspect bot} plug"
  end
  def start_link(mode, bot, otp_app, provider, opts) do
    IO.inspect "Opts coming: #{inspect opts}"
    Supervisor.start_link(__MODULE__, {mode, bot, otp_app, provider, opts}, [name: bot])
  end

  @spec bot_init(type :: :dry_run | :supervisor, bot :: Agala.Bot.t(), config :: Keyword.t()) ::
          {:ok, Keyword.t()} | :ignore
  defp bot_init(type, bot, config) do
    if Code.ensure_loaded?(bot) and function_exported?(bot, :init, 2) do
      bot.init(type, config)
    else
      {:ok, config}
    end
  end

  ## Callbacks

  @spec init({
    mode :: :poller, :plug, :handler,
    bot :: Agala.Bot.t(),
    otp_app :: atom(),
    provider :: Agala.Provider.t(),
    opts :: Keyword.t()
  }) :: {:ok, tuple()} | :ignore
  def init({:poller, bot, otp_app, provider, opts}) do
    case runtime_config(:poller, :supervisor, bot, otp_app, opts) do
      {:ok, opts} ->
        children = [
          {provider.get_bot(:poller), opts},
          {Agala.Bot.Storage, name: Module.concat(bot, Storage)}
        ]

        Supervisor.init(children, strategy: :one_for_one)
      :ignore ->
        :ignore
    end
  end
end
