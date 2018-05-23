defmodule Agala.Backbone.RabbitMQ.Transfer do
  @moduledoc false

  alias Agala.Backbone.RabbitMQ.Poolboy
  alias Agala.Backbone.RabbitMQ.Config

  # @moduledoc """
  # This module is responsive about message sending and retrieving to and from RabbitMQ Backbone
  # """

  def push(bot_name, cid, value) do
    with %AMQP.Channel{pid: pid} = chan <- Process.get(Agala.Backbone.RabbitMQ.Channel),
         true <- Process.alive?(pid) do
          ensured_push(chan, bot_name, cid, value)
    else
      _problems_with_channel ->
        {:ok, chan} = Poolboy.create_channel()
        Process.put(Agala.Backbone.RabbitMQ.Channel, chan)
        ensured_push(chan, bot_name, cid, value)
    end
  end

  def pull(bot_name) do
    with %AMQP.Channel{pid: pid} = chan <- Process.get(Agala.Backbone.RabbitMQ.Channel),
         true <- Process.alive?(pid) do
          ensured_pull(chan, bot_name)
    else
      _problems_with_channel ->
        {:ok, chan} = Poolboy.create_channel()
        Process.put(Agala.Backbone.RabbitMQ.Channel, chan)
        ensured_pull(chan, bot_name)
    end
  end

  defp ensured_pull(chan, bot_name) do
    case AMQP.Basic.get(chan, Config.get_queue_name(:in, bot_name), no_ack: true) do
      {:ok, data, _} -> {:ok, data}
      {:empty, _} -> {:error, :empty}
      error -> error
    end
  end

  defp ensured_push(chan, bot_name, cid, value) do
    case AMQP.Basic.publish(chan, "", Config.get_queue_name(:in, bot_name), :erlang.term_to_binary({cid, value})) do
      :ok -> :ok
      error -> {:error, error}
    end
  end
end
