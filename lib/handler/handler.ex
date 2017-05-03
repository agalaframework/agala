defmodule Agala.Handler do
  @moduledoc ~S"""
  A lot of super interesting documentation
  """

  @typep state :: any

  @callback handle(state, Agala.Model.Message.t) :: state

  defmacro __using__(_) do
    quote location: :keep do

      @behaviour Agala.Handler
      use GenServer

      # API

      @doc false
      defp via_tuple(name, id) do
        {:via, Registry, {Agala.Registry, {:handler, name, id}}
      end

      @doc false
      def start_link(bot_params, id) do
        GenServer.start_link(__MODULE__, [], name: via_tuple(bot_params.name, id))
      end

      @doc false
      @spec handle_message(term, any) :: :ok
      def handle_message(name, id, message) do
        GenServer.cast(via_tuple(name), {:handle_message, message})
      end

      # SERVER

      @doc false
      def handle_cast({:handle_message, message}, state) do
        {:noreply, handle(state, message)}
      end

    end
  end
end
