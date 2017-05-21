defmodule Agala.Response do
  defstruct [
    name: nil,
    method: :noaction,
    url: nil,
    body: nil,
    headers: nil,
    http_opts: nil
  ]

  @type t :: %Agala.Response{
    name: atom,
    method: :noaction | :get | :post | :put | :delete,
    url: String.t,
    body: String.t,
    headers: [{String.t, String.t}],
    http_opts: Keyword.t
  }
end
