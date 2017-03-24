defmodule AddressTooling.Address.Town do
  use Ecto.Schema
  use AddressTooling.Store, collection: "towns"

  schema "towns" do
    field :_id, :integer                 # UPSN and mongodb id
    field :area, :string                 # administrative area
    field :n, :string                    # name
  end

  def from_area(area), do: from %{area: area}, timeout: 120_006

  def from_name_area(town, area) do
    from(%{ n: town, area: area }, timeout: 120_007)
  end
end
