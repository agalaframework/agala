defmodule Agala.BotParams do

  @type t :: %Agala.BotParams{
    private: %{},
    name: atom,
    provider: atom,
    poller: atom,
    handler: atom,
    provider_params: %{},
    token: String.t,
    poll_timeout: integer,
    http_opts: Keyword.t
  }
  defstruct [:private, :name, :poller, :router, :handler, :token, :timeout, :http_opts]
end
