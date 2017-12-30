defmodule Agala.ExUnit.Assertations do
  def assert_response_with(match_expression) do
    Agent.get(Agala.CaseAgent, fn state ->
      state
      |> Enum.any?(&Kernel.match?(match_expression, &1))
    end)
  end
end
