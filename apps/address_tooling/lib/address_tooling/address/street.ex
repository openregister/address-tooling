defmodule AddressTooling.Address.Street do
  use Ecto.Schema
  use AddressTooling.Store, collection: "streets"

  alias AddressTooling.Address.Town

  schema "streets" do
    field :_id, :integer                 # UPSN and mongodb id
    field :c, :integer                   # street custodian id
    field :e, :date                      # end date
    field :l, :string                    # locality
    field :n, :string                    # address name as text - optional
    field :t, :string                    # town _id
    field :w, :string                    # welsh name
  end

  def from_town_id id do
    from(%{t: id}, timeout: 120_008)
  end

  def expand_town street do
    town = Town.from_id street.t
    case town do
      nil ->
        street
        |> Map.put(:town, nil)
        |> Map.put(:area, nil)
      _ ->
        street
        |> Map.put(:town, town.n)
        |> Map.put(:area, town.area)
    end
  end

  def expand street do
    street |> expand_town()
  end

end
