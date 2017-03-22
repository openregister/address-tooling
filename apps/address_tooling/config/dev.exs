use Mix.Config

# Configure your database
# config :address_tooling, AddressTooling.Repo,
#   adapter: Ecto.Adapters.Postgres,
#   username: "postgres",
#   password: "postgres",
#   database: "address_tooling_dev",
#   hostname: "localhost",
#   pool_size: 10
config :address_tooling, :db, name: "address_tooling_dev"
