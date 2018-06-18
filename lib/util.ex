defmodule Agala.Util do
  @doc """
  Method is used to retrieve `module`'s behaviour list.

  ### Example:
      defmodule FooBar do
        @behaviour Foo
        @Behaviour Bar
      end

      iex> Agala.Util.behaviours_list(FooBar)
      [Foo, Bar]
  """
  @spec behaviours_list(module :: atom()) :: [atom()]
  def behaviours_list(module) do
    module.module_info[:attributes]
    |> Enum.filter(fn {key, _} -> key == :behaviour end)
    |> Enum.map(fn {_, [value]} -> value end)
  end
end
