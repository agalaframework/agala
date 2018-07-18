defmodule Agala.Bot.Storage do
  @moduledoc """
  This module represent permanent storage system for Agala bot.

  ### The problem

  Sometimes, some bot parts can shut down because of internal errors. It has no
  sense to handle this errors in *letitcrash* approach. Thus, bot should have
  the place to store some data that should not be lost during restarts.

  Of course, developer should implement his own storage for business logic, but
  `providers` can use this storage to save internal data.

  ### Implementation

  `Agala.Storage` has two methods: `set/3` and `get/2`.
  This methods are used to keep and retrieve data.

  If this storage is fundamental, it's lifecycle will be unlinked from `Agala.Bot`
  instance. But, you can implement optional `child_spec/1` method. In this case,
  the `Agala.Storage` module will be started inside `Agala.Bot` supervision tree.
  """

  @doc false
  def child_spec(opts) do
    case Keyword.get(opts, :name) do
      nil ->
        raise ArgumentError,
          "option :name is not specified in Agala.Storage call"
      name ->
        %{
          id: name,
          start: {__MODULE__, :start_link, [name]},
          type: :worker
        }
    end
  end

  @doc false
  @spec start_link(name :: atom()) :: Agent.on_start
  def start_link(name), do: Agent.start_link(&Map.new/0, name: name)

  @spec set(bot :: Agala.Bot.t(), key :: Map.key, value :: Map.value) ::
    {:ok, Map.value}
  def set(bot, key, value) do
    {
      Agent.update(Module.concat(bot, Storage), fn map -> Map.put(map, key, value) end),
      value
    }
  end

  @spec get(bot :: Agala.Bot.t(), key :: Map.key) :: any
  def get(bot, key) do
    Agent.get(Module.concat(bot, Storage), fn map -> Map.get(map, key) end)
  end
end
