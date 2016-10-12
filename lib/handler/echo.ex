defmodule Agala.Handler.Echo do
  use Agala.Handler
  require Logger

  def state do
    []
  end

  def handle(state, message = %{"message" => %{"text" => text, "chat" => %{"id" => id}}}) do
    Logger.info("Handling message #{inspect message}")
    Agala.Bot.exec_cmd("sendMessage", %{chat_id: id, text: text})
    state
  end
end

