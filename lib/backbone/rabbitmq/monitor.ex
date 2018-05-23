defmodule Agala.Backbone.RabbitMQ.Monitor do
  @moduledoc false

  alias Agala.Backbone.RabbitMQ.Config
  alias Agala.Backbone.RabbitMQ.Poolboy

  @doc """
  This methods shows incoming message load for the bot
  """
  @spec get_load(bot_name :: Agala.Bot.name()) :: {:ok, integer()} | {:error, any()}
  def get_load(bot_name) do
    Poolboy.get_queue_message_count(Config.get_queue_name(:in, bot_name))
  end

  @doc """
  This method is used to initialize bot. It will:
  * init `in` and `out` channels
  """
  @spec init_bot(bot_name :: Agala.Bot.name()) :: :ok | {:error, any()}
  def init_bot(bot_name) do
    with {:ok, _} <- Poolboy.get_queue_message_count(Config.get_queue_name(:in, bot_name)),
         {:ok, _} <- Poolboy.get_queue_message_count(Config.get_queue_name(:out, bot_name)) do
      :ok
    else
      error -> error
    end
  end
end
