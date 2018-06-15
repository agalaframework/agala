defmodule Agala.Bot.Poller do
  @moduledoc """


  ### Using

  Include `Agala.Bot.Poller` into your supervision tree

  ### Example

      Supervisor.start_link([
        MyApp.TelegramPoller
      ], options)


  ### Poller inside provider

  Provider's poller should be a GenServer realization, that will take two params - Handler module and storage's pid
  """
  @behaviour Agala.Bot.Poller

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @behaviour Agala.Bot.Poller

      ## Check config

      use Supervisor

      def start_link(arg) do
        Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
      end

      @impl Supervisor
      def init(arg) do
        Supervisor.init([
          {Agala.Bot.Storage, name: Module.concat(__MODULE__, Storage)}
        ], strategy: :one_for_one)
      end
    end
  end
end
