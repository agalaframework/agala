defmodule Agala.Bot do
  @moduledoc """
  todo description about new bot
  """

  @behaviour Agala.Bot

  @typedoc """
  Bot is represented by it's name as atom
  """
  @type t :: atom()

  @doc """
  This function is used to **live reload** bot configuration in runtime after `sys.config` changing.

  Agala checks configuration in compile time, so this method will initiate `Agala.Bot` reconfiguration.
  `Agala.Bot` will consume new configuration from `sys.config` without any additional params.
  """
  @callback reconfigure() :: :ok | no_return

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @behaviour Agala.Bot
      @config_key Module.concat(__MODULE__, Config)

      ### Configuration section
      ### -----------------------------------------------------------------------------------

      # Configuring module
      # Method will raise in compile time, if config is not presented
      FastGlobal.put(@config_key, Agala.Bot.Supervisor.compile_config(__MODULE__, opts))

      def config, do: FastGlobal.get(Module)

      def reconfigure do
        FastGlobal.put(@config_key, Agala.Bot.Supervisor.compile_config(__MODULE__, opts))
      end
      ### -----------------------------------------------------------------------------------

      use Supervisor
      # Child spec is imported via `Supervisor` using


    end
  end

end
