defmodule AddressTooling.Address.Address do
  use Ecto.Schema
  use AddressTooling.Store, collection: "addresses"

  schema "addresses" do
    field :_id, :integer                 # UPRN and mongodb id
    field :a, :integer                   # address name id - optional
    field :c, :integer                   # street custodian id
    field :coordinates, {:array, :float} #
    field :e, :date                      # end date
    field :i, :integer                   # address name as integer - optional
    field :n, :string                    # address name as text - optional
    field :p, :string                    # postcode
    field :par, :integer                 # parent address UPRN - optional
    field :pri, :integer                 # primary address UPRN - optional
    field :s, :integer                   # USRN and street _id
    field :t, :string                    # town _id
    field :y, :string                    # property type
    field :w, :string                    # welsh name

    timestamps()
  end
end
