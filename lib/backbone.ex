defmodule Agala.Backbone do
  @moduledoc """
  This behaviour specifies protocol, that should be implemented for each and every backbone,
  that can be used with `Agala` framework.
  """

  @typedoc """
  Backbone is represented by it's name as Atom
  """
  @type t :: atom()

  @doc """
  This function is given to configure the backbone.
  """
  @callback bake_backbone_config() :: :ok | no_return()

  @doc """
  This function is used to retrieve backbone's config
  """
  @callback get_config() :: any()

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
  @callback get_load(bot_name :: atom()) :: {:ok, integer} | {:error, any()}

  @doc """
  This method is uused to initialize bot. It should be probably used upon bot initialization
  """
  @callback init_bot(bot_name :: atom()) :: :ok | {:error, any()}
  @doc """
  This method is used to add new element to the end of queue, defined by `Agala.Bot` and queue's **CID**
  """
  @callback push(bot_name :: Agala.Bot.name(), cid :: any(), value :: any()) ::
              :ok | {:error, any()}

  @doc """
  This method is used to pull available element from the queue, defined by `Agala.Bot`
  """
  @callback pull(bot_name :: Agala.Bot.name()) :: {:ok, any()} | {:error, :empty} |{:error, any()}

  # @doc """
  # This method will subscribe caller process to get new events from the bot.

  # Messages will be of type `Agala.Conn.t()`.
  # """
  # @callback subscribe(bot_name :: Agala.Bot.name()) :: {:ok, any()} | {:error, any()}

  ### -------------------------------------------------------------------------------------------------------------------------------------------------
  ### API
  ### -------------------------------------------------------------------------------------------------------------------------------------------------

  @doc """
  Returns supervision config for specififed backbone
  """
  @spec supervisor() :: atom()
  def supervisor() do
    case bake_backbone_config() do
      {:ok, backbone} -> backbone
    end
  end

  @doc """
  This function will check backbone configuration. If everything is right - `ok tuple` with `Agala.Backbone` implementation module
  will be returned. If it's not specified correct - function will rise.
  """
  @spec bake_backbone_config() :: {:ok, t} | no_return()
  def bake_backbone_config() do
    # Checking backbone
    backbone = Application.get_env(:agala, :backbone, nil)

    unless backbone do
      raise ArgumentError, "missing :backbone configuration in config :agala"
    end

    unless Code.ensure_loaded?(backbone) do
      raise ArgumentError, "backbone #{inspect backbone} was not compiled, " <>
                           "ensure it is correct and it is included as a module in the project"
    end

    unless Agala.Backbone in Agala.Util.behaviours_list(backbone) do
      raise ArgumentError, "backbone #{inspect backbone} does not implement Agala.Backbone behaviour, " <>
                           "ensure it is correct and it is included as a module in the project"
    end

    # All ok. Backing backbone specific config
    :ok = backbone.bake_backbone_config()
    {:ok, backbone}
  end
end
