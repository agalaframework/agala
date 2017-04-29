defmodule Agala.Config do
  @moduledoc """
  Encapsulates functions to fetch application configuration.
  """

  @default_timeout 3000
  @default_offset 0
  @default_router Agala.Router.Direct
  @default_handler Agala.Handler.Echo

  @doc ~S"""
  Gets timeout from configuration.

  ## Example
      iex> Agala.Config.timeout()
      3000
  """
  @spec timeout :: integer
  def timeout do
    Config.get_integer!(:agala, :request_timeout, default: @default_timeout)
  end

  @doc ~S"""
  Gets default offset.

  ## Example
      iex> Agala.Config.offset()
      0
  """
  @spec offset :: integer
  def offset, do: @default_offset

  @doc ~S"""
  Gets router from the configuration.

  ## Example
      iex> Agala.Config.router()
      Agala.Router.Direct
  """
  @spec router :: atom
  def router do
    Application.get_env(:agala, :router, @default_router)
  end

  @doc ~S"""
  Gets handler from configuration.

  ## Example
      iex> Agala.Config.handler()
      Agala.Handler.Echo
  """
  @spec handler :: atom
  def handler do
    Application.get_env(:agala, :handler, @default_handler)
  end

  @doc ~S"""
  Gets proxy from the configuration. The proxy should be
  regular URL as a string.

  ## Example
      iex> Agala.Config.proxy_url()
      "localhost:8080"
  """
  @spec proxy_url :: String.t
  def proxy_url do
    Config.get!(:agala, :proxy, default: nil)
  end


  @doc ~S"""
  Gets proxy user name.

  ## Example
      iex> Agala.Config.proxy_user()
      "Nickname"
  """
  @spec proxy_user :: String.t
  def proxy_user do
    Config.get!(:agala, :proxy_user, default: nil)
  end

  @doc ~S"""
  Gets proxy password.

  ## Example
      iex> Agala.Config.proxy_password()
      "password"
  """
  @spec proxy_password :: String.t
  def proxy_password do
    Config.get!(:agala, :proxy_password, default: nil)
  end

  @doc ~S"""
  Gets options for HTTPosion requests.

  ## Example
      iex> Agala.Config.http_opts()
      [{:key, :value}, ...]
  """
  @spec http_opts :: Keyword.t
  def http_opts do
    [recv_timeout: timeout()]
    |> set_proxy()
  end


  # Populates HTTPoison options with proxy configuration from application config.
  defp set_proxy(opts), do: resolve_proxy(opts, proxy_url(), proxy_user(), proxy_password())

  # Sets valid proxy opts depends on given config params
  defp resolve_proxy(opts, nil, _user, _password), do: opts
  defp resolve_proxy(opts, proxy, nil, nil), do: opts |> Keyword.put(:proxy, proxy)
  defp resolve_proxy(opts, proxy, proxy_user, proxy_password) do
    opts
    |> Keyword.put(:proxy, proxy)
    |> Keyword.put(:proxy_auth, {proxy_user, proxy_password})
  end

  @doc ~S"""
  Gets bot's access token.

  ## Example
      iex> Agala.Config.token()
      "2ef3..."
  """
  @spec token :: String.t
  def token do
    case Config.get(:agala, :token) do
      {:ok, token} -> token
      {:error, _} -> raise "Telegram API token should be specified!"
    end
  end
end
