defmodule Agala.Backbone.Mnesia do
  use GenServer
  require Logger
  @behaviour Agala.Backbone

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl GenServer
  def init(args) do
    :mnesia.start()
    {:ok, args}
  end

  # ### Agala.Backbone implimentation
  # @impl Agala.Backbone
  # def init() do
  #   # Ensure all nodes are added
  #   cluster_nodes = [Node.self() | Node.list()]
  #   case :mnesia.change_config(:extra_db_nodes, cluster_nodes) do
  #     {:ok, _} -> add_tables()
  #     error -> error
  #   end
  # end

  @impl Agala.Backbone
  def get_load(arg) do
    # TODO: This is stab
    {:ok, arg}
  end

  @impl Agala.Backbone
  def push(a, b, c) do
    # TODO: This is stab
    {:ok, {a, b, c}}
  end

  defp add_tables() do
    # Тут надо добавить какие-то таблицы
    Logger.debug("Adding some tables")
    {:ok, :mnesia_cluster_initialized}
  end

  defp create_table(table_name, opts) do
    current_node = Node.self()
    case :mnesia.create_table(table_name, opts) do
      {:atomic, :ok} ->
        Logger.debug(fn -> "#{inspect table_name} was successfully created" end)
        :ok
      {:aborted, {:already_exists, ^table_name}} ->
        # table already exists, trying to add table copy to current node
        create_table_copy(table_name)
      {:aborted, {:already_exists, ^table_name, ^current_node}} ->
        # table already exists, trying to add table copy to current node
        create_table_copy(table_name)
      error ->
        Logger.error(fn -> "Error while creating #{inspect table_name}: #{inspect error}" end)
        {:error, error}
    end
  end

  defp create_table_copy(table_name) do
    current_node = Node.self()
    # wait for table
    :mnesia.wait_for_tables([table_name], 10000)
    # add copy
    case :mnesia.add_table_copy(table_name, current_node, :ram_copies) do
      {:atomic, :ok} ->
        Logger.debug(fn -> "Copy of #{inspect table_name} was successfully added to current node" end)
        :ok
      {:aborted, {:already_exists, table_name}} ->
        Logger.debug(fn -> "Copy of #{inspect table_name} is already added to current node" end)
        :ok
      {:aborted, {:already_exists, table_name, current_node}} ->
        Logger.debug(fn -> "Copy of #{inspect table_name} is already added to current node" end)
        :ok
      {:aborted, reason} ->
        Logger.error(fn -> "Error while creating copy of #{inspect table_name}: #{inspect reason}" end)
        {:error, :reason}
    end
  end
end
