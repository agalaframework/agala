defmodule Support.Random.Reciever do
  use Agala.Bot.Receiver

  def get_updates(callback, bot_params) do
    for number <- 1..10 do
      callback.(number)
    end
    bot_params
  end
end
