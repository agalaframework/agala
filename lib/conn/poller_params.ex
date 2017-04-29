defmodule Agala.Conn.PollerParams do

  @type t :: %Agala.Conn.PollerParams{
    offset: integer,
    router: atom,
    handler: atom,
    token: String.t,
    timeout: integer,
    http_opts: Keyword.t
  }
  defstruct [:offset, :router, :handler, :token, :timeout, :http_opts]


  @spec defaults :: Agala.Conn.PollerParams.t
  def defaults do
    %Agala.Conn.PollerParams{
      offset: Agala.Config.offset(),
      router: Agala.Config.router(),
      handler: Agala.Config.handler(),
      token: Agala.Config.token(),
      timeout: Agala.Config.timeout(),
      http_opts: Agala.Config.http_opts()
    }
  end
end
