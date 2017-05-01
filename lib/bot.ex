defmodule Agala.Bot do
  use Supervisor

  defp via_tuple(name) do
    {:via, Registry, {Agala.Registry, {:bot, name}}
  end

  def start_link(bot_params) do
    Supervisor.start_link(__MODULE__, bot_params, name: via_tuple(bot_params.name))
  end

  def init(bot_params) do
    children = [
      worker(Agala.PollServer, [bot_params])
      supervisor(bot_params.router, [bot_params])
    ]

    # supervise/2 is imported from Supervisor.Spec
    supervise(children, strategy: :one_for_one)
  end
end
