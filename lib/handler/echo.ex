defmodule Agala.Handler.Echo do
  use Agala.Handler
  require Logger

  alias Agala.Bot, as: Bot

  @moduledoc """
  Simple echo handler - returns the incoming message back to the user.
  """

  def init(_) do
    {:ok, []}
  end

  def handle(state, message = %{"message" => %{"text" => text, "chat" => %{"id" => id}}}) do
    Logger.info("Handling message #{inspect message}")
    Bot.exec_cmd("sendMessage", %{chat_id: id, text: text})
    state
  end
end
