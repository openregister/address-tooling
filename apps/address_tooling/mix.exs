defmodule AddressTooling.Mixfile do
  use Mix.Project

  def project do
    [app: :address_tooling,
     version: "0.0.1",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {AddressTooling.Application, []},
     extra_applications: [:logger]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    # [{:postgrex, ">= 0.0.0"},
    [{:ecto, "~> 2.1-rc"},
    {:mongodb, ">= 0.0.0"},
    {:data_morph, ">= 0.0.0"}]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    # ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
    #  "ecto.reset": ["ecto.drop", "ecto.setup"],
    #  "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
    ["address.load": ["run priv/repo/seeds.exs"]]
  end
end
