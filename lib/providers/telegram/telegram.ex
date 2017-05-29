defmodule Agala.Provider.Telegram do
  def base_url(conn) do
    "https://api.telegram.org/bot" <> conn.poller_params.token
  end

  def init(bot_params) do
    Map.put(bot_params, :private, %{
      http_opts: Keyword.new
                 |> set_proxy(bot_params)
                 |> set_timeout(bot_params),
      offset: 0,
      timeout: get_in(bot_params, [:provider_params, :poll_timeout])
    })
  end
  defp set_timeout(http_opts, bot_params) do
    http_opts
    |> Keyword.put(:recv_timeout, get_in(bot_params, [:provider_params, :poll_timeout]) || 5000)
  end
  # Populates HTTPoison options with proxy configuration from application config.
  defp set_proxy(http_opts, bot_params) do
    resolve_proxy(Keyword.new,
      get_in(bot_params, [:provider_params, :proxy_url]),
      get_in(bot_params, [:provider_params, :proxy_user]),
      get_in(bot_params, [:provider_params, :proxy_password])
    )
  end
  # Sets valid proxy opts depends on given config params
  defp resolve_proxy(opts, nil, _user, _password), do: opts
  defp resolve_proxy(opts, proxy, nil, nil), do: opts |> Keyword.put(:proxy, proxy)
  defp resolve_proxy(opts, proxy, proxy_user, proxy_password) do
    opts
    |> Keyword.put(:proxy, proxy)
    |> Keyword.put(:proxy_auth, {proxy_user, proxy_password})
  end

  def response(conn, bot_params) do
    # Here is telegram answer
  end
end
