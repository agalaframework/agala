defmodule Agala.Bot.Plug do
  @moduledoc """
  This module can be used to build **Bots** to retrieve updates from third-parties
  as webhooks.
  """
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      use Plug.Builder

      {otp_app, provider, config} = Agala.Bot.Config.compile_config(:plug, __MODULE__, opts)

      @otp_app otp_app
      @provider provider
      @config config

      @doc """
      Retreives module's configuration.
      """
      @spec config() :: Map.t()
      def config, do: @config

      # First we need to store bot options inside connection
      plug(:config_to_private)

      # Then just passing control to plug, specified in provider,
      # and passing there bot's configuration
      plug(provider.get_bot(:plug), config)

      @doc false
      def config_to_private(conn, _opts) do
        conn
        |> Plug.Conn.put_private(:agala_bot_config, @config)
      end
    end
  end
end
