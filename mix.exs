defmodule Agala.Mixfile do
  use Mix.Project

  def project do
    [app: :agala,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :httpoison, :gproc],
     mod: {Agala, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:httpoison, "~> 0.9.2"},
      {:poison, "~> 3.0"},
      {:gproc, "~> 0.6.1"},
      {:ex_doc, ">=0.0.0", only: :dev}
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
      files: ~w(mix.exs README* lib)
    ]
  end
end

