defmodule Agala.Handler do
  @moduledoc ~S"""
  A lot of super interesting documentation
  """

  @typep state :: any
  
  @callback state() :: state

  @callback handle(state, %{}) :: state

  defmacro __using__(_) do
    quote location: :keep do
    
      @behaviour Agala.Handler
      use GenServer

      # API

      @doc false
      def start_link(name) do
        GenServer.start_link(__MODULE__, state, name: via_tuple(name))
      end

      @doc false
      defp via_tuple(name) do
        {:via, :gproc, {:n, :l, {:handler_echo, name}}}
      end

      @doc false
      def handle_message(name, message) do
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
