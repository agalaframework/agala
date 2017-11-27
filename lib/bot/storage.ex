defmodule Agala.Bot.Storage do
  @moduledoc """
  Behavior for modules that represent permanent storage system for Agala bot.

  ### The problem

  Sometimes, some bot parts can shut down because of internal errors. It has no
  sense to handle this errors in *letitcrash* approach. Thus, bot should have
  the place to store some data that should not be lost during restarts.

  Of cource, developer should implement his own storage for business logic, but
  `providers` can use this storage to save internal data.

  ### Implementation

  Each `Agala.Storage` should mandatory implement two methods: `set/3` and `get/2`.
  This methods are used to keep and retrieve data.

  If this storage is fundamental, it's lifecycle will be unlinked from `Agala.Bot`
  instance. But, you can implement optional `child_spec/1` method. In this case,
  the `Agala.Storage` module will be started inside `Agala.Bot` supervision tree.
  """

  @callback child_spec(
    bot_params :: Agala.BotParams.t
  ) :: :supervisor.child_spec

  @callback set(
    bot_params :: Agala.BotParams.t,
    key :: Map.key,
    value :: Map.value
  ) :: {:ok, Map.value}

  @callback get(
    bot_params :: Agala.BotParams.t,
    key :: Map.key
  ) :: Map.value

  @optional_callbacks child_spec: 1
end
