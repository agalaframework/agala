# defmodule Agala.RouterTest do
#   use ExUnit.Case

#   alias Agala.RouterTest.TestRouter

#   doctest Agala.Router

#   setup do
#     {:ok, router} = TestRouter.start_link

#     on_exit fn ->
#       GenServer.stop(router)
#     end

#     {:ok, process: router}
#   end

#   test "the truth" do
#     assert 1 + 1 == 2
#   end
# end

# defmodule Agala.RouterTest.TestRouter do
#   use Agala.Router

#   def handler_ids(message) do
#     :test
#   end
# end
