defmodule AddressTooling.Address.AddressName do
  use Ecto.Schema
  use AddressTooling.Store, collection: "address_names"

  schema "address_names" do
    field :_id, :integer                 # UPRN and mongodb id
    field :n, :string                    # address name as text - optional
  end

end
