defmodule Agala.Provider.Telegram.Responser do
  defmacro __using__(_) do
    quote location: :keep do
      defp create_body(conn = %Agala.Conn{response: %{payload: %{body: body}}}) when is_bitstring(body), do: body
      defp create_body(conn = %Agala.Conn{response: %{payload: %{body: body}}}) when is_map(body), do: body
      defp create_body(conn), do: ""

      defp create_url(conn = %Agala.Conn{response: %{payload: %{url: url}}}, bot_params) when is_function(url) do
        url.(bot_params.provider_params.token)
      end

      def response(conn, bot_params) do
        HTTPoison.request(
          conn.response.method,
          create_url(conn, bot_params),
          create_body(conn),
          Map.get(conn.response, :headers, []),
          Map.get(conn.response, :http_opts) || Map.get(bot_params.private, :http_opts) || []
        )
      end
    end
  end
end
