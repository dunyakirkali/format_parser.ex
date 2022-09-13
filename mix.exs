defmodule FormatParser.Mixfile do
  use Mix.Project

  def project do
    [
      app: :format_parser,
      version: "1.3.2",
      elixir: "~> 1.4",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      package: package(),
      description: description(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test],
      aliases: aliases()
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
      {:excoveralls, "~> 0.14.0", only: :test},
      {:ex_doc, "~> 0.28.4", only: :dev},
      {:credo, "~> 1.6.1", only: [:dev, :test], runtime: false},
      {:doctor, "~> 0.19.0", only: :dev},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false}
    ]
  end

  # Package Information
  defp package do
    [
      files: ["test", "lib", "mix.exs", "README.md", "LICENSE*"],
      maintainers: ["Dunya Kirkali", "Onur Kucukkece"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/ahtung/format_parser.ex"}
    ]
  end

  # Package description
  defp description do
    """
    The owls are not what they seem
    """
  end

  defp aliases do
    [
      code_quality: ["credo --strict", "dialyzer", "doctor"]
    ]
  end
end
