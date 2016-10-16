defmodule Agala do
  use Application
  require Logger

  @moduledoc """
  Main framework module. Copy readme from github here
  """

  @default_timeout 100
  @default_router Agala.Router.Direct
  @default_handler Agala.Handler.Echo

  @doc """
  Main function, starts the supervision tree
  """
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    token = get_token
    Logger.info("Starting Agala server...")
    Logger.info("Defined token: #{token}")
    children = [
      worker(Agala.Bot.Poller, [
        %{timeout: get_timeout, offset: 0}
        |> set_proxy
      ]),
      supervisor(Task.Supervisor, [[name: Agala.Bot.TasksSupervisor]]),
      supervisor(get_router(), [])
    ]

    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end

  @doc """
  Gets timeout from configuration
  """
  def get_timeout do
    Application.get_env(:agala, :request_timeout) || @default_timeout 
  end

  @doc """
  Gets router from the configuration
  """
  def get_router do
    Application.get_env(:agala, :router) || @default_router
  end

  @doc """
  Gets handler from configuration
  """
  def get_handler do
    Application.get_env(:agala, :handler) || @default_handler
  end

  @doc """
  Gets proxy from the configuration
  """
  def get_proxy do
    Application.get_env(:agala, :proxy) || nil
  end


  @doc """
  Gets proxy auth parameters from the configuration
  """
  def get_proxy_auth do
    Application.get_env(:agala, :proxy_auth) || nil
  end

  defp set_proxy(opts) do
    resolve_proxy(opts, get_proxy, get_proxy_auth)
  end
  defp resolve_proxy(opts, nil, _auth) do
    opts
  end
  defp resolve_proxy(opts, proxy, nil) do
    opts
    |> Map.put(:proxy, proxy)
  end
  defp resolve_proxy(opts, proxy, proxy_auth) do
    opts
    |> Map.put(:proxy, proxy)
    |> Map.put(:proxy_auth, proxy_auth)
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

