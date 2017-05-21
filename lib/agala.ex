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

    Logger.info("Starting Agala server")
    children = [
      supervisor(Registry, [:unique, Agala.Registry]),
      worker(Agala.Responser, [], name: Agala.Responser)
    ]

    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end

  def response_with(conn) do
    GenServer.cast(
      Agala.Bot.Responser.via_tuple(conn.response.name),
      conn
      )
  end
end
