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

    Supervisor.start_link([
      worker(AddressTooling.Repo, []),
    ], strategy: :one_for_one, name: AddressTooling.Supervisor)
  end
end
