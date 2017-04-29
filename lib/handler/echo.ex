defmodule Agala.Handler.Echo do
  use Agala.Handler
  require Logger

  alias Agala.Conn
  import Agala.Client.Telegram

  @moduledoc """
  Simple echo handler - returns the incoming message back to the user.
  """

  def init(_) do
    {:ok, []}
  end

  def handle(conn = %Agala.Conn{request: %{"message" => %{"text" => text, "chat" => %{"id" => id}}}}) do
    Logger.info("Handling message #{inspect message}")
    
    conn
    |> send_message(chat_id, text)
  end

  def handle(token, message = %{"message" => %{"text" => text, "chat" => %{"id" => id}}}) do
    Logger.info("Handling message #{inspect message}")
    Bot.exec_cmd("sendMessage", token, %{chat_id: id, text: text})
    token
  end
end
