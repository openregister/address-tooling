defmodule AddressTooling.Address.Address do
  use Ecto.Schema
  use AddressTooling.Store, collection: "addresses"

  alias AddressTooling.Address.Address
  alias AddressTooling.Address.AddressName
  alias AddressTooling.Address.Street

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
  end

  def expand_address_name(map) do
    case map do
      %{a: id} ->
        name = AddressName.from_id(id)
        map |> Map.put(:n, name.n)
      _ -> map
    end
  end

  def expand_integer_name(map) do
    case map do
      %{i: i} ->
        map |> Map.put(:n, i |> Integer.to_string )
      _ -> map
    end
  end

  def expand_street address do
    street = if address |> Map.has_key?(:s) do
      address.s |> Street.from_id()
    else
      nil
    end
    case street do
      nil ->
        address
        |> Map.put(:street, nil)
        |> Map.put(:locality, nil)
        |> Map.put(:town, nil)
      _ ->
        address
        |> Map.put(:street, street.n)
        |> Map.put(:locality, street[:l])
        |> Map.put(:town, street[:town])
    end
  end

  def expand address do
    address
    |> expand_address_name()
    |> expand_integer_name()
    |> expand_street()
  end

  def from_address_names address_names do
    address_names
    |> Enum.map(& &1._id)
    |> Enum.flat_map(& Address.from(%{a: &1}, expand: true))
  end

  def from_name text do
    case Integer.parse(text) do
      {integer, ""} ->
        Address.from(%{i: integer}, expand: true, timeout: 300_000)
      {integer, _} ->
        AddressName.from_name(text)
        |> from_address_names()
        |> Enum.concat( Address.from(%{n: text}, expand: true, timeout: 300_000) )
        |> Enum.concat( Address.from(%{i: integer}, expand: true, timeout: 300_000) )
      :error ->
        AddressName.from_name(text)
        |> from_address_names()
        |> Enum.concat( Address.from(%{n: text}, expand: true, timeout: 300_000) )
    end
  end

  def from_street_id id, opts \\ [expand: true] do
    from(%{s: id}, opts |> Keyword.merge([timeout: 120_009]))
  end

  def from_parent_id id, opts \\ [expand: true] do
    from(%{par: id}, opts |> Keyword.merge([timeout: 300_000]))
  end
end
