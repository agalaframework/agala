defmodule Agala.UtilTest do
  use ExUnit.Case, async: true
  alias Agala.Util

  describe "behaviours_list" do
    test "return empty list for void module" do
      defmodule A do
      end

      assert [] = Util.behaviours_list(A)
    end

    test "return valid list for module full of behaviours" do
      defmodule A do
        @behaviour Foo
        @behaviour Bar
        @behaviour A.B.C
      end

      assert Foo in Util.behaviours_list(A)
      assert Bar in Util.behaviours_list(A)
      assert A.B.C in Util.behaviours_list(A)
    end
  end
end
