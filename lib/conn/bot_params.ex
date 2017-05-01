defmodule Agala.BotParams do

  @type t :: %Agala.BotParams{
    private: %{},
    name: atom,
    poller: atom,
    router: atom,
    handler: atom,
    token: String.t,
    poll_timeout: integer,
    http_opts: Keyword.t
  }
  defstruct [:private, :name, :poller, :router, :handler, :token, :timeout, :http_opts]


  @spec defaults(name :: atom) :: Agala.BotParams.t
  def defaults(name) do
    %Agala.BotParams{
      private: %{offset: Agala.Config.offset()},
      name: name,
      poller: Agala.Config.poller(),
      router: Agala.Config.router(),
      handler: Agala.Config.handler(),
      token: Agala.Config.token(),
      poll_timeout: Agala.Config.timeout(),
      http_opts: Agala.Config.http_opts()
    }
  end
end
