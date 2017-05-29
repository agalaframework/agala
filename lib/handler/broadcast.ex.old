defmodule Agala.Handler.Broadcast do
  use Agala.Handler
  require Logger

  alias Agala.Bot, as: Bot

  @moduledoc """
  Broadcast bot handler. Use it to broadcast some information from your bot to chanel.

  ### Getting your `chat_id` for Private Chanel

  Getting your `chat_id` for now is not so easy. Perform these steps:

  * Turn you chanel to public, so it will get id like `@MyChannel`
  * Send cURL request to Web Bot API
      ```bash
      curl -X POST "https://api.telegram.org/bot%YOURBOTTOKEN%/sendMessage"\
   -d "chat_id=@MyChannel&text=my sample text"
      ```
  * Get response in form of:
      ```bash
      { "ok" : true, "result" : { "chat" : { "id" : -1001005582487, ...
      ```
  * Extract `id` from response, it will not be changed anymore
  * Turn your chanel back to private
  """

  @chat_id "-1001072726818"

  def init(_) do
    {:ok, []}
  end

  def handle(state, text) do
    Logger.info("Broadcasting message:\n#{text} \n    to chat\n#{@chat_id}")
    resp = Bot.exec_cmd("sendMessage", %{chat_id: @chat_id, text: text})
    Logger.info("Message is #{inspect resp}")
    state
  end
end

#{:ok, broad} = Agala.Handler.Broadcast.start_link(:broad)
#Agala.Handler.Broadcast.handle_message(:broad, "Text")