defmodule Agala.Bot.Poller do
  @moduledoc """


  ### Using

  Include `Agala.Bot.Poller` into your supervision tree

  ### Example

      Supervisor.start_link([
        MyApp.TelegramPoller
      ], options)


  ### Poller inside provider

  Provider's poller should be a GenServer realisation, that will take two params - Handler module and storage's pid
  """

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @behaviour Agala.Bot.Poller

      {otp_app, provider, config} = Agala.Bot.Config.compile_config(:poller, __MODULE__, opts)

      @otp_app otp_app
      @provider provider
      @config config

      def config() do
        {:ok, config} = Agala.Bot.Supervisor.runtime_config(:poller, :dry_run, __MODULE__, @otp_app, @config)
      end

      def child_spec(opts) do
        %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, [opts]},
          type: :supervisor
        }
      end

      def start_link(opts \\ []) do
        Agala.Bot.Supervisor.start_link(:poller, __MODULE__, @otp_app, @provider, @config)
      end

      def stop(pid, timeout \\ 5000) do
        Supervisor.stop(pid, :normal, timeout)
      end
    end
  end
end
