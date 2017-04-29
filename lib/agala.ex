defmodule Agala do
  use Application
  require Logger

  @moduledoc """
  Main framework module. Copy readme from github here
  """

  @doc """
  Main function, starts the supervision tree
  """
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    token = Agala.Config.token()
    Logger.info("Starting Agala server")
    children = [
      worker(Agala.Bot.Poller, [Agala.Bot.PollerParams.defaults()]),
      supervisor(Agala.Config.router(), [Agala.Config.handler()])
    ]

    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end
end
