use Mix.Config

# Configure your database
config :address_tooling, AddressTooling.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "address_tooling_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
