# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :address_tooling_web,
  namespace: AddressTooling.Web,
  ecto_repos: [AddressTooling.Repo]

# Configures the endpoint
config :address_tooling_web, AddressTooling.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "uGNIIPM9opd2OkbQ05lhFsStlPUzjTfKvzNF97wAExlaRk7fmRhj1V4xj0OD8Nq6",
  render_errors: [view: AddressTooling.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: AddressTooling.Web.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
