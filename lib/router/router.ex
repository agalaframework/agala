defmodule Agala.Router do
  @moduledoc ~S"""
  Router behaviour specification.
  """

  @type message :: any

  @type handler_id :: term

  @callback handler_ids(message) :: [handler_id]
  @callback handler_id(message) :: handler_id

  @callback route(message) :: any

  defmacro __using__(_) do
    quote location: :keep do

      @behaviour Agala.Router

      use Supervisor
      require Logger

      # Initialisation

      @doc false
      def start_link(handler) do
        Supervisor.start_link(__MODULE__, handler, name: __MODULE__)
      end

      @doc false
      def init(handler) do
        children = [
          worker(handler, [], restart: :transient)
        ]
        supervise(children, strategy: :simple_one_for_one)
      end

      # Routing

      @doc false
      def route(message, %Agala.Bot.PollerParams{token: token, handler: handler}) do
        for hid <- get_handler_list(message) do
          hid
          |> start_handler(token)
          |> handler.handle_message(message)
          Logger.debug("Routing message to handler with id #{inspect hid}")
        end
      end

      @typep hid :: term # handler_id type

      def get_handler_list(message) do
        hids = handler_ids(message)
      end

      def start_handler(hid, token) do
        Supervisor.start_child(__MODULE__, [{hid, token}])
        hid
      end
    end
  end
end
