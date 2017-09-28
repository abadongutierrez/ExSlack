defmodule ExSlack.Mixfile do
  use Mix.Project

  @version "0.0.1-dev"

  def project do
    [
      app: :ex_slack,
      version: @version,
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 0.13"},
      {:poison, "~> 3.1"},
      {:socket, "~> 0.3"}

      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end

  defp description do
    """
    A Slack Real Time Message API and Web API client for Elixir.
    """
  end

  defp package do
    [
      maintainers: ["Rafael Gutiérrez"],
      licenses: ["MIT License"],
      links: %{"GitHub" => "https://github.com/abadongutierrez/ExSlack"}
    ]
  end
end
