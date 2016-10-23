defmodule Agala.Router do
  @moduledoc ~S"""
  Router behaviour specification.
  """

  @type message :: any

  @callback handler_id(message) :: term
  
  @callback route(message) :: any

  defmacro __using__(_) do
    quote location: :keep do

      @behaviour Agala.Router

      use Supervisor
      require Logger

      @default_handler Agala.Handler.Echo

      # Initialisation

      @doc false
      def start_link do
        Supervisor.start_link(__MODULE__, [], name: __MODULE__)
      end

      @doc false
      def init(_) do
        children = [
          worker(Agala.get_handler(), [], restart: :transient)
               ]

            supervise(children, strategy: :simple_one_for_one)
      end

      # Routing

      @doc false
      def route(message) do
        hid = start_handler(message)
        Logger.debug("Routing message to handler with id #{inspect hid}")
        Agala.get_handler().handle_message(hid, message)
      end

      @typep hid :: term # handler_id type 

      @spec start_handler(Agala.Router.message) :: hid
      def start_handler(message) do
        hid = handler_id(message)
        Supervisor.start_child(__MODULE__, [hid])
        hid
      end
    end
  end
end
