defmodule Agala.Conn do
  @moduledoc """
  The Agala connection.

  This module defines a `Agala.Conn` struct. This struct contains
  both request and response data.

  ## Request fields


  These fields contain request information:

    * `request` - request data structure. It's internal structure depends
    on provider type.
  """

  defstruct [
    request: nil,
    response: nil,
    halted: false,
    request_bot_params: %Agala.BotParams{},
    responser_name: nil,
    multi: nil
  ]

  @type t :: %Agala.Conn{
    request: Map.t,
    response: Map.t,
    halted: boolean,
    request_bot_params: Agala.BotParams.t,
    responser_name: String.t | Atom,
    multi: Agala.Conn.Multi.t
  }

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

  @doc """
  Halts the Agala.Chain pipeline by preventing further plugs downstream from being
  invoked. See the docs for `Agala.Chain.Builder` for more information on halting a
  Chain pipeline.
  """
  @spec halt(t) :: t
  def halt(%Agala.Conn{} = conn) do
    %{conn | halted: true}
  end

  @doc """
  Specifies the name for the bot, which will send the response back
  to side APIs.
  """
  def send_to(%Agala.Conn{} = conn, name) do
    conn
    |> Map.put(:responser_name, name)
  end
end
