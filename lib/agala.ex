defmodule Agala do
  use Application
  require Logger


  @default_timeout 1
  @default_router Agala.Router.Direct
  @default_handler Agala.Handler.Echo

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    token = get_token
    Logger.info("Starting Agala server...")
    Logger.info("Defined token: #{token}")
    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: Agala.Worker.start_link(arg1, arg2, arg3)
      # worker(Agala.Worker, [arg1, arg2, arg3]),
      worker(Agala.Bot.Poller, [%{timeout: get_timeout, offset: 0}]),
      supervisor(Task.Supervisor, [[name: Agala.Bot.TasksSupervisor]]),
      supervisor(get_router(), [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end

  def get_timeout do
    Application.get_env(:agala, :request_timeout) || @default_timeout 
  end

  def get_router do
    Application.get_env(:agala, :router) || @default_router
  end

  def get_handler do
    Application.get_env(:agala, :handler) || @default_handler
  end

  def get_token do
    token_name = Application.get_env(:agala, :token_env)
    if (is_nil(token_name)) do
      raise "Invalid token variable name. Please define :agala, :token_name in config.exs"
    else
      get_token_from_env(token_name)
    end
  end

  defp get_token_from_env(token_name) do
    token = System.get_env(token_name)
    if (is_nil(token)) do
      raise "Invalid token name. Please export token to environment variable with name defined in :agala, :token_name in config.exs"
    else
      token
    end
  end
end

