use Mix.Config

config :address_tooling, ecto_repos: [AddressTooling.Repo]

import_config "#{Mix.env}.exs"
