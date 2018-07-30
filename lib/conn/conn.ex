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
    assigns: %{},
    request: nil,
    response: nil,
    halted: false,
    private: %{},
    request_bot_params: %Agala.BotParams{},
    responser: nil,
    responser_name: nil,
    multi: nil,
  ]

  @type t :: %Agala.Conn{
    assigns: Map.t,
    request: Map.t,
    response: Map.t,
    halted: boolean,
    private: Map.t,
    request_bot_params: Agala.BotParams.t,
    responser_name: String.t | Atom,
    responser: String.t | Atom,
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
  Halts the Agala.Chain pipeline by preventing further chains downstream from being
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
    |> Map.put(:responser, name)
  end

  @doc """
  Assigns a value to a key in the connection
  ## Examples
      iex> conn.assigns[:hello]
      nil
      iex> conn = assign(conn, :hello, :world)
      iex> conn.assigns[:hello]
      :world
  """
  @spec assign(t, atom, term) :: t
  def assign(%Agala.Conn{assigns: assigns} = conn, key, value) when is_atom(key) do
    %{conn | assigns: Map.put(assigns, key, value)}
  end

  @doc """
  Starts a task to assign a value to a key in the connection.
  `await_assign/2` can be used to wait for the async task to complete and
  retrieve the resulting value.
  Behind the scenes, it uses `Task.async/1`.
  ## Examples
      iex> conn.assigns[:hello]
      nil
      iex> conn = async_assign(conn, :hello, fn -> :world end)
      iex> conn.assigns[:hello]
      %Task{...}
  """
  @spec async_assign(t, atom, (() -> term)) :: t
  def async_assign(%Agala.Conn{} = conn, key, fun) when is_atom(key) and is_function(fun, 0) do
    assign(conn, key, Task.async(fun))
  end

  @doc """
  Awaits the completion of an async assign.
  Returns a connection with the value resulting from the async assignment placed
  under `key` in the `:assigns` field.
  Behind the scenes, it uses `Task.await/2`.
  ## Examples
      iex> conn.assigns[:hello]
      nil
      iex> conn = async_assign(conn, :hello, fn -> :world end)
      iex> conn = await_assign(conn, :hello) # blocks until `conn.assigns[:hello]` is available
      iex> conn.assigns[:hello]
      :world
  """
  @spec await_assign(t, atom, timeout) :: t
  def await_assign(%Agala.Conn{} = conn, key, timeout \\ 5000) when is_atom(key) do
    task = Map.fetch!(conn.assigns, key)
    assign(conn, key, Task.await(task, timeout))
  end

  @doc """
  Assigns a new **private** key and value in the connection.
  This storage is meant to be used by libraries and frameworks to avoid writing
  to the user storage (the `:assigns` field). It is recommended for
  libraries/frameworks to prefix the keys with the library name.
  For example, if some plug needs to store a `:hello` key, it
  should do so as `:plug_hello`:
      iex> conn.private[:plug_hello]
      nil
      iex> conn = put_private(conn, :plug_hello, :world)
      iex> conn.private[:plug_hello]
      :world
  """
  @spec put_private(t, atom, term) :: t
  def put_private(%Agala.Conn{private: private} = conn, key, value) when is_atom(key) do
    %{conn | private: Map.put(private, key, value)}
  end

  @doc """
  Specifies the lambda function that will be called after the result of
  provider's respponse to the bot's response will appear.
  The lambda shuld have only one parameter - `Agala.Conn.t` for current connection.
  It'll have `request` with request to bot, `response` with response from bot, and
  `fallback` with response sending results.
  """
  def with_fallback(%Agala.Conn{} = conn, fallback_callback) do
    conn
    |> Map.put(:fallback, fallback_callback)
  end
end