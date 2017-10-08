defmodule Agala.Storage.Local do
  defp via_tuple(name) do
    {:global, {:agala, :storage, name}}
  end

  @spec start_link(bot_params :: Agala.BotParams.t) :: Agent.on_start
  def start_link(bot_params) do
    Agent.start_link(&Map.new/0, name: via_tuple(bot_params.name))
  end

  @spec set(bot_params :: Agala.BotParams.t, key :: Map.key, value :: Map.value) ::
    {:ok, Map.value}
  def set(bot_params, key, value) do
    {
      Agent.update(via_tuple(bot_params.name), fn map -> Map.put(map, key, value) end),
      value
    }
  end

  def get(bot_params, key) do
    Agent.get(via_tuple(bot_params.name), fn map -> Map.get(map, key) end)
  end
end
