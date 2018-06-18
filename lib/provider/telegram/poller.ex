defmodule Agala.Provider.Telegram.Poller do
  @moduledoc """

  ### How poller works?

  Poller gets all needed options in `start_link/1` argument. In these options `:chain`
  is specified.

  So the Poller make periodical work:

  1. HTTP get new updates from Telegram server
  2. Split this array into separate event
  3. Handle particular each event with chain
  4. Restart cycle again
  """
  def start_link(_bot, opts) do
    Agent.start_link(fn -> Map.new(opts) end)
  end
end
