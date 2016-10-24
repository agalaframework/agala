defmodule Agala.Router.User do
  use Agala.Router
  require Logger

  @moduledoc """
  Simple router, which defines message author
   and pass the message directly to separate handler.
  """
  def handler_id(%{"message" => %{"chat" => %{"id" => user_id}}}) do
    user_id
  end

end
