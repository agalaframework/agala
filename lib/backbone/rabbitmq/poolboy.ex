defmodule Agala.Backbone.RabbitMQ.Poolboy do
  @moduledoc false

  def create_channel() do
    :poolboy.transaction(
        Agala.Backbone.RabbitMQ.ConnectionPool,
        fn pid -> Agala.Backbone.RabbitMQ.Connection.open_channel(pid) end,
        10000
      )
  end

  def get_queue_message_count(queue_name) do
    :poolboy.transaction(
        Agala.Backbone.RabbitMQ.ConnectionPool,
        fn pid -> Agala.Backbone.RabbitMQ.Connection.get_queue_message_count(pid, queue_name) end,
        10000
      )
  end
end
