defmodule Agala do
  use Application

  alias Agala.Config

  def start(_start_type, _start_args) do
    # Make some configurations
    Agala.Backbone.supervisor()
    # |> Kernel.++(another_configuration_map)
    |> Supervisor.start_link(strategy: :one_for_one, name: Agala.Application)
  end

  ### Backbone direct calls

  @doc """
  This method is used to show bot's **receive <-> handle** load.

  * **Active Receivers** can use this information in order to stop retrieving new updates from third-parties.
  * **Passive Receivers** can use this information to stop serving for a moment until load will not decrease.

  Example:

      # For active receivers

      def get_updates() do
        # check if service is overloaded
        case Agala.Backbone.Foo.get_load(MyApp.MyBot) do
          {:ok, overload} when overload > 1000 ->
            # This server is overloaded
            # waiting a bit, to let handlers deal with overload
            :timer.sleep(10_000)
            download_updates()
          {:ok, normal} ->
            # We should not wait - load is normal
            download_updates()
        end
      end

      # For passive receivers
      def call(conn, opts) do
        # check if service is overloaded
        case Agala.Backbone.Foo.get_load(MyApp.MyBot) do
          {:ok, overload} when overload > 1000 ->
            # This server is overloaded
            # Stop serving
            send_500_http_error(conn)
          {:ok, normal} ->
            # We should not wait - load is normal
            proceed_update(conn)
        end
      end
  """
  @spec get_load(bot_name :: Agala.Bot.t()) :: {:ok, integer} | {:error, any()}
  def get_load(bot_name), do: Config.get_backbone().get_load(bot_name)

  @doc """
  # TODO: Docs and examples
  """
  def push(bot_name, cid, value), do: Config.get_backbone().push(bot_name, cid, value)

  @doc """
  # TODO: Docs and examples
  """
  def pull(bot_name), do: Config.get_backbone().pull(bot_name)

  ### Storage

  @doc """
  Sets given `value` under given `key` across bot's supervisor lifetime.
  Can be usefull to store some state across restarting handlers, responsers
  and receivers.
  """
  def set(bot_params, key, value) do
    Agala.Bot.Storage.set(bot_params.bot, key, value)
  end

  @doc """
  Gets the value, stored under the given `key` across bot's supervisor lifetime.
  Can be usefull to reveal some state across restarting handlers, responsers
  and receivers.
  """
  def get(bot_params, key) do
    Agala.Bot.Storage.get(bot_params.bot, key)
  end
end
