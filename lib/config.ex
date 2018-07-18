defmodule Agala.Config do

  @doc """
  Returns current configured backbone as `Agala.Backbone` module.

  Can be used to perform direct calls to defined backbone.
  """
  @spec get_backbone() :: Agala.Backbone.t()
  def get_backbone() do
    Application.get_env(:agala, :backbone)
  end
end
