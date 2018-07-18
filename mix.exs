defmodule Agala.MixProject do
  use Mix.Project

  def project do
    [
      app: :agala,
      version: "3.0.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      description: description(),
      elixirc_paths: elixirc_paths(Mix.env()),
      package: package(),
      aliases: aliases(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      docs: docs(),
      deps: deps()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      mod: {Agala, []},
      extra_applications: [:logger]
    ]
  end

  defp aliases do
    [
      test: "test --no-start"
    ]
  end

  defp deps do
    [
      # Dev and test dependecies
      {:ex_doc, "~> 0.18", only: :dev},
      {:inch_ex, "~> 0.5", only: [:dev, :test, :docs]},
      {:credo, "~> 0.8", only: [:dev, :test]},
      {:excoveralls, "~> 0.9", only: :test}
    ]
  end

  defp description do
    """
    Full featured messaging bot framework.
    """
  end

  defp docs do
    [
      main: "getting-started",
      logo: "extras/agala.svg.png",
      extras: [
        "extras/Getting Started.md",
        "extras/Bots.md",
        "extras/Providers.md",
        "extras/Usage.md",
        "extras/Handlers.md",
        "extras/General Configuration.md"
      ]
    ]
  end

  defp package do
    [
      maintainers: ["Dmitry Rubinstein"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/agalaframework/agala"},
      files: ~w(mix.exs README* CHANGELOG* lib)
    ]
  end
end
