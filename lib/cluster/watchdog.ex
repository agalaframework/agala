defmodule Agala.Cluster.Watchdog do
  @moduledoc """
  Singleton watchdog process
  Each node that the singleton runs on, runs this process. It is
  responsible for starting the singleton process (with the help of
  Erlang's 'global' module).
  When starting the singleton process fails, it instead monitors the
  process, so that in case it dies, it will try to start it locally.
  The singleton process is started using the `GenServer.start_link`
  call, with the given module and args.
  """

  use GenServer
  require Logger

  @doc """
  Start the manager process, registering it under a unique name.

  ## Example
    {Agala.Cluster.Watchdog, [Agala.Bot, [:params], name: {:global, {:agala, :bot, :one}}]}
  """
  def start_link(module, args, opts) do
    GenServer.start_link(
      __MODULE__,
      [module, args, opts],
      name: get_watchdog_name(name)
    )
  end

  @moduledoc false
  defmodule State do
    defstruct pid: nil, module: nil, args: nil, opts: nil
  end

  @doc false
  def init([module, args, opts]) do
    state = %State{module: module,
                   args: args,
                   opts: opts}
    {:ok, start_supervised_module(state)}
  end

  @doc false
  def handle_info({:DOWN, _, :process, pid, :normal}, state = %State{pid: pid, module: module}) do
    # Managed process exited normally. Shut manager down as well.
    case module.child_spec.restart do
      :permanent -> {:noreply, start_supervised_module(state)}
      :temporary -> {:stop, :normal, state}
      :transient -> {:stop, :normal, state}
    end
  end
  def handle_info({:DOWN, _, :process, pid, :shutdown}, state = %State{pid: pid, module: module}) do
    # Managed process exited normally. Shut manager down as well.
    case module.child_spec.restart do
      :permanent -> {:noreply, start_supervised_module(state)}
      :temporary -> {:stop, :shutdown, state}
      :transient -> {:stop, :shutdown, state}
    end
  end
  def handle_info({:DOWN, _, :process, pid, {:shutdown, term}}, state = %State{pid: pid, module: module}) do
    # Managed process exited normally. Shut manager down as well.
    case module.child_spec.restart do
      :permanent -> {:noreply, start_supervised_module(state)}
      :temporary -> {:stop, {:shutdown, term}, state}
      :transient -> {:stop, {:shutdown, term}, state}
    end
  end
  def handle_info({:DOWN, _, :process, pid, reason}, state = %State{pid: pid, module: module}) do
    # Managed process exited abnormaly. Trying to restart.
    {:noreply, start_supervised_module(state)
  end

  defp start_supervised_module(state) do
    start_result = GenServer.start_link(state.mod, state.args, name: {:global, state.name})
    pid = case start_result do
            {:ok, pid} -> pid
            {:error, {:already_started, pid}} -> pid
          end
    Process.monitor(pid)
    %State{state | pid: pid}
  end

  defp get_name(module, args, opts) do
    case Keyword.get(opts, :name) do
      nil ->
        case module.name_spec(args) do
          {:global, value} -> value
          _ ->
        end
      {:global, value} -> value
      _ -> raise(ArgumentError, "global name for module #{module} is undefined"
    end
  end
  defp get_watchdog_name(name) do
    String.to_atom("#{__MODULE__}##{inspect get_name(module, args, opts)}")
  end
end
