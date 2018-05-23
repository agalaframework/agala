defmodule Agala.Backbone.RabbitMQ.Config do
  @moduledoc false

  alias Agala.Backbone.RabbitMQ.Config

  @spec get_connection_config() :: Keyword.t() | no_return()
  def get_connection_config() do
    FastGlobal.get(Agala.Backbone.RabbitMQ)
    |> Map.drop([:pool_size, :domain])
    |> Map.to_list()
  end

  def get_config() do
    FastGlobal.get(Agala.Backbone.RabbitMQ)
  end

  def get_config(key) when is_atom(key) do
    FastGlobal.get(Agala.Backbone.RabbitMQ)[key]
  end

  def set_config(config) do
    FastGlobal.put(Agala.Backbone.RabbitMQ, config)
  end

  @spec bake_backbone_config() :: :ok | no_return()
  def bake_backbone_config() do
    FastGlobal.put(
      Agala.Backbone.RabbitMQ,
      Enum.into(Application.get_env(:agala, Agala.Backbone.RabbitMQ), %{})
    )
  end

  @spec get_queue_name(:in | :out, Agala.Bot.name) :: String.t()
  def get_queue_name(direction, bot_name) do
    "#{Atom.to_string(Config.get_config(:domain))}.#{Atom.to_string(bot_name)}.#{Atom.to_string(direction)}"
  end
end
