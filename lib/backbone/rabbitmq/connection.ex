defmodule Agala.Backbone.RabbitMQ.Connection do
  @moduledoc false
  use GenServer

  alias Agala.Backbone.RabbitMQ.Config

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg, [])
  end

  ### API
  @doc """
  This method is used to open a channel inside pool of connections.
  """
  @spec open_channel(pid :: pid()) :: {:ok, AMQP.Channel.t} | {:error, any()}
  def open_channel(pid) do
    GenServer.call(pid, :open_channel)
  end

  @doc """
  This method will get the queue message count, by queue name
  """
  def get_queue_message_count(pid, queue_name) do
    GenServer.call(pid, {:get_queue_message_count, queue_name})
  end

  def init(_arg) do
    # We are initializing Connection with empty state
    {:ok, {nil, nil}}
  end

  # Handlers

  def handle_call(:open_channel, _from, {nil, nil}) do
    # This case covers initial situation, when connection is not opened yet
    {:ok, connection, monitor_channel} = init_monitored_connection()
    {:reply, AMQP.Channel.open(connection), {connection, monitor_channel}}
  end
  def handle_call(:open_channel, _from, {connection, channel}) do
    # This case is if connection is already opened
    # Adds new connection
    {:reply, AMQP.Channel.open(connection), {connection, channel}}
  end

  def handle_call({:get_queue_message_count, queue_name}, _from, {nil, nil}) do
    # This case covers initial situation, when connection is not opened yet
    {:ok, connection, monitor_channel} = init_monitored_connection()

    reply = case AMQP.Queue.declare(monitor_channel, queue_name) do
      {:ok, %{message_count: message_count}} ->
        {:ok, message_count}
      error -> error
    end
    {:reply, reply, {connection, monitor_channel}}
  end
  def handle_call({:get_queue_message_count, queue_name}, _from, {connection, channel}) do
    # This case covers initial situation, when connection is opened
    reply = case AMQP.Queue.declare(channel, queue_name) do
      {:ok, %{message_count: message_count}} ->
        {:ok, message_count}
      error -> error
    end
    {:reply, reply, {connection, channel}}
  end

  def handle_info({:DOWN, _ref, :process, _object, _reason}, {connection, channel}) do
    case Process.alive?(connection.pid) do
      true ->
        # If channel dies - we try to respawn it if connection survived
        {:ok, %AMQP.Channel{pid: pid} = channel} = AMQP.Channel.open(connection)
        Process.monitor(pid)
        {:noreply, {connection, channel}}

      false ->
        # If connection is dead also - we do nothing
        {:noreply, {nil, nil}}
    end
  end

  ### Helpers

  # This method is used to start the connection, and to monitor it
  defp init_monitored_connection() do
    {:ok, connection} = AMQP.Connection.open(Config.get_connection_config())

    {:ok, %AMQP.Channel{pid: pid} = channel} = AMQP.Channel.open(connection)
    Process.monitor(pid)

    {:ok, connection, channel}
  end
end
