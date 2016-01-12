defmodule StopWatch.Mixfile do
  use Mix.Project

  def project do
    [app: :stopwatch,
     version: "0.0.1",
     elixir: "~> 1.0",
     description: "The stopwatch provide methods to profile code",
     package: package,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :tzdata],
     mod: {Stopwatch, []}]
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
    [{:timex, "~> 1.0"},
     {:dialyxir, "~> 0.3", only: [:dev]}]
  end

  defp description do
    """
    The stopwatch provides an easy api to measure elapsed time and
    profile code.
    """
  end

  defp package do
    [
      maintainers: ["Matteo Giachino"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/matteosister/stopwatch"}
    ]
  end
end
