defmodule AddressTooling.Address.Town do
  use Ecto.Schema
  use AddressTooling.Store, collection: "towns"

  schema "towns" do
    field :_id, :integer                 # UPSN and mongodb id
    field :area, :string                 # administrative area
    field :n, :string                    # name

    timestamps()
  end

end
