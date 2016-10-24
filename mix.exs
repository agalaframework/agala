defmodule Agala.Mixfile do
  use Mix.Project

  def project do
    [app: :agala,
     version: "1.0.2",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps()]
  end

  def application do
    [applications: [:logger, :httpoison, :gproc],
     mod: {Agala, []}]
  end

  defp deps do
    [
      {:httpoison, "~> 0.9.2"},
      {:poison, "~> 3.0"},
      {:gproc, "~> 0.6.1"},
      {:ex_doc, "~> 0.14.3", only: :dev},
      {:inch_ex,"~> 0.5.5", only: :docs},
      {:credo, "~> 0.4", only: [:dev, :test]}
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

