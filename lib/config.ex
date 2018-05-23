defmodule Agala.Config do
  def get_backbone() do
    Application.get_env(:agala, :backbone)
  end
end
