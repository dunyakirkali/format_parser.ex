defmodule FormatParser.Mixfile do
  use Mix.Project

  def project do
    [
      app: :format_parser,
      version: "1.4.0",
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
      {:excoveralls, "~> 0.18.5", only: :test},
      {:ex_doc, "~> 0.34", only: :dev},
      {:credo, "~> 1.7.11", only: [:dev, :test], runtime: false},
      {:doctor, "~> 0.22.0", only: :dev},
      {:dialyxir, "~> 1.4.5", only: [:dev], runtime: false}
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
