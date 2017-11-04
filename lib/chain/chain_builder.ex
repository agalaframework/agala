defmodule Agala.Chain.Builder do
  @type chain :: module | atom

  @doc false
  defmacro __using__(opts) do
    quote do
      @behaviour Agala.Chain
      @chain_builder_opts unquote(opts)

      def init(opts) do
        opts
      end

      def call(conn, opts) do
        chain_builder_call(conn, opts)
      end

      defoverridable [init: 1, call: 2]

      import Agala.Conn
      import Agala.Chain.Builder, only: [chain: 1, chain: 2]

      Module.register_attribute(__MODULE__, :chains, accumulate: true)
      @before_compile Agala.Chain.Builder
    end
  end

  @doc false
  defmacro __before_compile__(env) do
    chains       = Module.get_attribute(env.module, :chains)
    builder_opts = Module.get_attribute(env.module, :chain_builder_opts)

    {conn, body} = Agala.Chain.Builder.compile(env, chains, builder_opts)

    quote do
      defp chain_builder_call(unquote(conn), _), do: unquote(body)
    end
  end

  @doc """
  A macro that stores a new chain. `opts` will be passed unchanged to the new
  chain.

  This macro doesn't add any guards when adding the new chain to the pipeline;
  for more information about adding chains with guards see `compile/1`.

  ## Examples
      chain Agala.Chain.Logger        # chain module
      chain :foo, some_options: true  # chain function
  """
  defmacro chain(chain, opts \\ []) do
    quote do
      @chains {unquote(chain), unquote(opts), true}
    end
  end

  @doc """
  Compiles a chain pipeline.

  Each element of the chain pipeline (according to the type signature of this
  function) has the form:
  ```
  {chain_name, options, guards}
  ```

  Note that this function expects a reversed pipeline (with the last chain that
  has to be called coming first in the pipeline).

  The function returns a tuple with the first element being a quoted reference
  to the connection and the second element being the compiled quoted pipeline.

  ## Examples
      Agala.Chain.Builder.compile(env, [
        {Agala.Chain.Logger, [], true}, # no guards, as added by the Agala.Chain.Builder.chain/2 macro
        {Agala.Chain.Head, [], quote(do: a when is_binary(a))}
      ], [])
  """
  @spec compile(Macro.Env.t, [{chain, Agala.Chain.opts, Macro.t}], Keyword.t) :: {Macro.t, Macro.t}
  def compile(env, pipeline, builder_opts) do
    conn = quote do: conn
    {conn, Enum.reduce(pipeline, conn, &quote_chain(init_chain(&1), &2, env, builder_opts))}
  end

  # Initializes the options of a chain at compile time.
  defp init_chain({chain, opts, guards}) do
    case Atom.to_charlist(chain) do
      ~c"Elixir." ++ _ -> init_module_chain(chain, opts, guards)
      _                -> init_fun_chain(chain, opts, guards)
    end
  end

  defp init_module_chain(chain, opts, guards) do
    initialized_opts = chain.init(opts)

    if function_exported?(chain, :call, 2) do
      {:module, chain, initialized_opts, guards}
    else
      raise ArgumentError, message: "#{inspect chain} chain must implement call/2"
    end
  end

  defp init_fun_chain(chain, opts, guards) do
    {:function, chain, opts, guards}
  end

  # `acc` is a series of nested chain calls in the form of
  # chain3(chain2(chain1(conn))). `quote_chain` wraps a new chain around that series
  # of calls.
  defp quote_chain({chain_type, chain, opts, guards}, acc, env, builder_opts) do
    call = quote_chain_call(chain_type, chain, opts)

    error_message = case chain_type do
      :module   -> "expected #{inspect chain}.call/2 to return a Agala.Conn"
      :function -> "expected #{chain}/2 to return a Agala.Conn"
    end <> ", all chains must receive a connection (conn) and return a connection"

    {fun, meta, [arg, [do: clauses]]} =
      quote do
        case unquote(compile_guards(call, guards)) do
          %Agala.Conn{halted: true} = conn ->
            unquote(log_halt(chain_type, chain, env, builder_opts))
            conn
          %Agala.Conn{} = conn ->
            unquote(acc)
          _ ->
            raise unquote(error_message)
        end
      end

    generated? = :erlang.system_info(:otp_release) >= '19'

    clauses =
      Enum.map(clauses, fn {:->, meta, args} ->
        if generated? do
          {:->, [generated: true] ++ meta, args}
        else
          {:->, Keyword.put(meta, :line, -1), args}
        end
      end)

    {fun, meta, [arg, [do: clauses]]}
  end

  defp quote_chain_call(:function, chain, opts) do
    quote do: unquote(chain)(conn, unquote(Macro.escape(opts)))
  end

  defp quote_chain_call(:module, chain, opts) do
    quote do: unquote(chain).call(conn, unquote(Macro.escape(opts)))
  end

  defp compile_guards(call, true) do
    call
  end

  defp compile_guards(call, guards) do
    quote do
      case true do
        true when unquote(guards) -> unquote(call)
        true -> conn
      end
    end
  end

  defp log_halt(chain_type, chain, env, builder_opts) do
    if level = builder_opts[:log_on_halt] do
      message = case chain_type do
        :module   -> "#{inspect env.module} halted in #{inspect chain}.call/2"
        :function -> "#{inspect env.module} halted in #{inspect chain}/2"
      end

      quote do
        require Logger
        # Matching, to make Dialyzer happy on code executing Agala.Chain.Builder.compile/3
        _ = Logger.unquote(level)(unquote(message))
      end
    else
      nil
    end
  end
end
