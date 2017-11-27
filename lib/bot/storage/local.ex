defmodule Agala.Bot.Storage.Local do
  @moduledoc """
  Basic `Agala.Storage` implimentation. The data is stored in `Agent`, that is started
  under `Agala.Bot` supervisor tree.
  """
  @behaviour Agala.Bot.Storage

  @doc false
  def child_spec(bot_params = %{name: name}) do
    %{
      id: "Agala.Storage.Local##{name}",
      start: {Agala.Storage.Local, :start_link, [bot_params]},
      type: :worker
    }
  end

  defp via_tuple(name) do
    {:global, {:agala, :storage, name}}
  end

  @doc false
  @spec start_link(bot_params :: Agala.BotParams.t) :: Agent.on_start
  def start_link(bot_params) do
    case Agent.start_link(&Map.new/0, name: via_tuple(bot_params.name)) do
      {:ok, pid} ->
        Process.register(pid, :"#Agala.Bot.Storage<#{bot_params.name}>")
        {:ok, pid}
      fail -> fail
    end
  end

  @spec set(bot_params :: Agala.BotParams.t, key :: Map.key, value :: Map.value) ::
    {:ok, Map.value}
  def set(bot_params, key, value) do
    {
      Agent.update(via_tuple(bot_params.name), fn map -> Map.put(map, key, value) end),
      value
    }
  end

  @spec get(bot_params :: Agala.BotParams.t, key :: Map.key) :: any
  def get(bot_params, key) do
    Agent.get(via_tuple(bot_params.name), fn map -> Map.get(map, key) end)
  end
end
