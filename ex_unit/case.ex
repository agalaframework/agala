defmodule Agala.ExUnit.Case do
  use ExUnit.CaseTemplate
  import Agala.ExUnit.Assertations

  setup_all do
    Agent.start_link(fn -> []] end, name: Agala.CaseAgent)
  end
end
