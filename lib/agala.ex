defmodule Agala do
  use Application

  alias Agala.Config

  def start(_start_type, _start_args) do
    # make some configurations
    Supervisor.start_link(
      [
        # starting backbone
        Agala.Backbone.supervisor()
      ],
      strategy: :one_for_one,
      name: Agala.Application
    )
  end

  ### Backbone direct calls
  def get_load(bot_name), do: Config.get_backbone().get_load(bot_name)

  @doc """
  # TODO: Docs and examples
  """
  def push(bot_name, cid, value), do: Config.get_backbone().push(bot_name, cid, value)

  @doc """
  # TODO: Docs and examples
  """
  def pull(bot_name), do: Config.get_backbone().pull(bot_name)
end
