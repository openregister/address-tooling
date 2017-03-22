defmodule AddressTooling.Application do
  @moduledoc """
  The AddressTooling Application Service.

  The address_tooling system business domain lives in this application.

  Exposes API to clients such as the `AddressTooling.Web` application
  for use in channels, controllers, and elsewhere.
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Supervisor.start_link([
    #   worker(AddressTooling.Repo, []),
    # ], strategy: :one_for_one, name: AddressTooling.Supervisor)

    # Define workers and child supervisors to be supervised
    children = [
      # supervisor(AddressTooling.Endpoint, []),
      # 1. Start mongo
      worker(Mongo, [[database:
        Application.get_env(:address_tooling, :db)[:name], name: :mongo]])
    ]

    opts = [strategy: :one_for_one, name: AddressTooling.Supervisor]
    result = Supervisor.start_link(children, opts)

    # 2. Indexes
    AddressTooling.Startup.ensure_indexes
    result
  end

end
