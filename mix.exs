defmodule Agala.Mixfile do
  use Mix.Project

  def project do
    [app: :agala,
     version: "1.0.3",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     aliases: aliases(),
     deps: deps()]
  end

  def application do
    [
      applications: [:logger, :httpoison, :gproc],
      mod: {Agala, []}
    ]
  end

  defp aliases do
    [
      test: "test --no-start"
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 0.11"},
      {:poison, "~> 3.1"},
      {:gproc, "~> 0.6.1"},
      {:config, github: "renderedtext/ex-config"},
      {:ex_doc, "~> 0.15", only: :dev},
      {:inch_ex,"~> 0.5", only: :docs},
      {:credo, "~> 0.7", only: [:dev, :test]}
    ]
  end

  defp description do
    """
    Full featured Telegram bot framework.
    """
  end

  defp package do
    [
      maintainers: ["Dmitry Rubinstein", "Vladimir Barsukov"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/virviil/agala"},
      files: ~w(mix.exs README* CHANGELOG* lib)
    ]
  end
end

