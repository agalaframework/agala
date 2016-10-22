defmodule Agala.Router.User do
  use Agala.Router
  require Logger

  def handler_id(%{"message" => %{"chat" => %{"id" => user_id}}}) do
    user_id
  end

end
