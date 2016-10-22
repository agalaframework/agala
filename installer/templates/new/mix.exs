defmodule <%= app_module %>.Mixfile do
  use Mix.Project

  def project do
    [app: :<%= app_name %>,
     version: "0.0.1",<%= if in_umbrella do %>
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",<% end %>
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      applications: [:logger, :agala]
    ]
  end

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      <%= agala_dep %>
    ]
  end
end

