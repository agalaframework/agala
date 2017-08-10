defmodule Agala.BotParams do
  @moduledoc """
  This module specified generic system for configuration all the variety of `Agala` bots.
  It helps to keep types of the params in consistence.

  Every `Agala` bot requires some common params, and also requires some specific params
  for only that bot type. Both of them can be specified in `BotParams` structure.

  So, the params are:
  * `name` - name for specific bot. You can read about names and why they are so important.
  * `provider` - the name of the `provider` which will be used in this bot. You can
    read about them here.
  * `handler` - handler's pipline, which will work with incomming messages and do all
    the business logic. Thees modules you will create during your application development.
    You can read about handlers pipline here.
  * `provider_params` - params, that are needed only for specified `provider`. Agala
    framework does not define any structure for these params, you can find it in your
    `provider`s documentation.
  * `private` - sepcial place to put some additional information. These params can be
    precalculated by the internal processes of initiation for your provider, or to cache
    some data. In common situations you should not use it at all, until you are developing
    your own `provider`.

  `BotParams` will be piped throw all the processes of your bot's lifecycle, untill
  the message will be finaly sent to the external environment.
  """
  @type t :: %Agala.BotParams{
    private: %{},
    name: String.t | atom,
    provider: atom,
    handler: atom,
    provider_params: Map.t
  }
  defstruct [:private, :name, :provider, :handler, :provider_params]

  @behaviour Access
  @doc false
  def fetch(bot_params, key) do
    Map.fetch(bot_params, key)
  end

  @doc false
  def get(structure, key, default \\ nil) do
    Map.get(structure, key, default)
  end

  @doc false
  def get_and_update(term, key, list) do
    Map.get_and_update(term, key, list)
  end

  @doc false
  def pop(term, key) do
    {get(term, key), term}
  end
end
