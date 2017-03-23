defmodule AddressTooling.Address.Street do
  use Ecto.Schema
  use AddressTooling.Store, collection: "streets"

  schema "streets" do
    field :_id, :integer                 # UPSN and mongodb id
    field :c, :integer                   # street custodian id
    field :e, :date                      # end date
    field :l, :string                    # locality
    field :n, :string                    # address name as text - optional
    field :t, :string                    # town _id
    field :w, :string                    # welsh name

    timestamps()
  end

end
