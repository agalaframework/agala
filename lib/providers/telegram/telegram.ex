defmodule Agala.Provider.Telegram do
  def base_url(conn) do
    "https://api.telegram.org/bot" <> conn.poller_params.token
  end

  def send_message(conn, chat_id, message, opts \\ []) do
    HTTPoison.request(
      :post,
      base_url <> "/sendMessage",
      opts |> Keyword.put(:chat_id, chat_id) |> Keuword.put(:text, text) |> Enum.into(%{}) |> Poison.encode!,
      [],
      conn.bot_params.http_opts
    )
  end
end
