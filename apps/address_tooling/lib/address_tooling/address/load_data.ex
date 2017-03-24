defmodule AddressTooling.Address.LoadData do
  alias AddressTooling.Address.Address
  alias AddressTooling.Address.AddressName
  alias AddressTooling.Address.Street
  alias AddressTooling.Address.Town

  def to_structs(line, type, :csv), do: line |> DataMorph.structs_from_csv(LoadData, type)
  def to_structs(line, type, :tsv), do: line |> DataMorph.structs_from_tsv(LoadData, type)

  def stream_load file, collection, type, csv_tsv, to_map do
    file
    |> File.stream!
    |> to_structs(type, csv_tsv)
    |> Stream.map(& to_map.(&1))
    |> Stream.chunk(1000, 1000, [])
    |> Enum.each(& &1 |> collection.insert_many)
  end

  def create_index_for name, collection, key, opts do
    unique = opts |> Keyword.get(:unique, true)
    sparse = opts |> Keyword.get(:sparse, false)
    database = Application.get_env(:address_tooling, :db)[:name]

    IO.puts inspect(database)
    IO.puts inspect(name)
    IO.puts inspect(collection)
    IO.puts inspect(key)
    IO.puts inspect(unique)
    IO.puts inspect(sparse)
    IO.puts inspect("#{database}.#{collection}")
    # Mongo.delete_many!(:mongo, "system.indexes", %{name: name})
    #
    # Mongo.insert_one!(:mongo, "system.indexes",
    #    %{name: name, ns: "#{database}.#{collection}",
    #    key: key, unique: unique, sparse: sparse},
    #    timeout: 1_200_000)

    Mongo.command(:mongo, [createIndexes: collection,
         indexes: [ %{ key: key,
                       name: name,
                       unique: unique,
                       sparse: sparse} ] ],
         timeout: 1_200_000)
    Mongo.find(:mongo, "system.indexes", %{name: name}, timeout: 120_002)
    |> Enum.to_list
    |> inspect
    |> IO.puts
  end

  def create_index(suffix, module, key, opts \\ []) do
    name = module.collection() <> "_" <> suffix
    create_index_for name, module.collection(), key, opts
  end

  def present?(nil), do: false
  def present?(""), do: false
  def present?(_), do: true

  def put_if_present map, key, value, parse\\false do
    if present?(value) do
      value = if parse do
                parse_id(value)
              else
                value
              end
      map |> Map.put(key, value)
    else
      map
    end
  end

  def parse_id(nil), do: nil
  def parse_id(""), do: nil
  def parse_id(id), do: String.to_integer(id)

  def town_map(id, name, area), do: %{_id: parse_id(id), n: name, area: area}

  def town town_administrative_area do
    case town_administrative_area |> String.split("|") do
      [town] -> town
      [town, _area] -> town
    end
  end

  def area town_administrative_area do
    case town_administrative_area |> String.split("|") do
      [area] -> area
      [_town, area] -> area
    end
  end

  def load_towns file do
    Mongo.delete_many!(:mongo, Town.collection, %{})
    file
    |> stream_load(Town, TownItem, :tsv, &(town_map(
      &1.town_id,
      town(&1.town_administrative_area),
      area(&1.town_administrative_area))
    ))

    create_index "n", Town, %{n: 1}, unique: false
    create_index "area", Town, %{area: 1}, unique: false
  end

  def address_name_map(id, name), do: %{_id: parse_id(id), n: name}

  def load_address_names file do
    file
    |> stream_load(AddressName, AddressNameItem, :tsv, &(address_name_map &1.id, &1.name))

    create_index "n", AddressName, %{n: 1}
  end

  def street_map(usrn, name, name_cy, locality, street_custodian, end_date, town_id) do
    map = %{
      _id: parse_id(usrn),
      n: name,
      c: parse_id(street_custodian),
      t: parse_id(town_id)
    }
    map = map |> put_if_present(:w, name_cy)
    map = map |> put_if_present(:l, locality)
    map = map |> put_if_present(:e, end_date)
    map
  end

  def town_admin_name town, area do
    UniqueAndCount.town_admin(UniqueAndCount.strip_dot(town), UniqueAndCount.strip_dot(area))
  end

  def load_streets_from file, town_admin_to_id do
    file
    |> stream_load(Street, StreetItem, :tsv, &(street_map(
      &1.street,
      &1.name,
      &1.name_cy,
      &1.locality,
      &1.street_custodian,
      &1.end_date,
      town_admin_to_id[ town_admin_name(&1.town, &1.administrative_area) ]
    )))
  end

  def town_admin_to_id file do
    file
    |> File.stream!
    |> CSV.decode(separator: ?\t, headers: true)
    |> Map.new(& {&1["town-administrative-area"], &1["town-id"]})
  end

  def load_streets path, town_file do
    town_admin_to_id = town_admin_to_id(town_file)
    street_files(path)
    |> Enum.each(& &1 |> load_streets_from(town_admin_to_id))
  end

  def index_streets do
    create_index "n", Street, %{n: 1}, unique: false
    create_index "w", Street, %{w: 1}, unique: false, sparse: true
    create_index "t", Street, %{t: 1}, unique: false
    create_index "l", Street, %{l: 1}, unique: false, sparse: true
  end

  def add_town_id map, street_id do
    if street_id do
      if street = Street.from_id(street_id, expand: false, timeout: 120_005) do
        map |> put_if_present(:t, street.t)
      else
        map
      end
    else
      map
    end
  end

  def add_address_name(map, nil, _), do: map
  def add_address_name(map, "", _), do: map
  def add_address_name(map, name, cache) do
    an_id = address_name_id(name, cache)
    case an_id do
      nil ->
        case Integer.parse(name) do
          {val, ""} -> map |> Map.put(:i, val)
          {_, _}    -> map |> Map.put(:n, name)
          :error    -> map |> Map.put(:n, name)
        end
      _ ->
        map |> Map.put(:a, an_id)
    end
  end

  def id_lookup collection, query, cache do
    lookup collection, :_id, query, cache
  end

  def lookup collection, field, query, cache do
    case :ets.lookup cache, {field, query} do
      [{_, value}] ->
        value
      [] ->
        value = case Mongo.distinct(:mongo, collection, field, query, limit: 1, timeout: 120_004) do
          {:ok, [val]} -> val
          {:ok, []} -> nil
        end
        :ets.insert cache, { {field, query}, value}
        value
    end
  end

  def address_name_id name, cache do
    id_lookup(AddressName.collection, %{n: name}, cache)
  end

  def address_map(cache, uprn, street, name, name_cy, point, end_date, street_custodian, postcode, property_type, parent_address, primary_address) do
    {coord, _} = point |> Code.eval_string
    street_id = parse_id(street)
    map = %{
      _id: parse_id(uprn),
      s: street_id,
      c: parse_id(street_custodian),
      p: postcode,
      y: property_type,
      coordinates: coord,
    }
    map = map |> add_town_id(street_id)
    map = map |> add_address_name(name, cache)

    map = map |> put_if_present(:w, name_cy)
    map = map |> put_if_present(:e, end_date)
    map = map |> put_if_present(:pri, primary_address, true)
    map = map |> put_if_present(:par, parent_address, true)
    map
  end

  def load_addresses file, cache do
    IO.puts file
    stream_load(file, Address, AddressItem, :tsv, &(address_map(
      cache,
      &1.address,
      &1.street,
      &1.name,
      &1.name_cy,
      &1.point,
      &1.end_date,
      &1.street_custodian,
      &1.postcode,
      &1.property_type,
      &1.parent_address,
      &1.primary_address))
    )
  end

  def load_addresses path do
    cache = :ets.new(:cache, [:set, :public])

    address_files(path)
    # |> Enum.filter(& &1 |> String.contains?("9010"))
    |> Enum.each(& &1 |> load_addresses(cache))
  end

  def index_addresses do
    create_index "p", Address, %{p: 1}, unique: false
    create_index "a", Address, %{a: 1}, unique: false, sparse: true
    create_index "n", Address, %{n: 1}, unique: false, sparse: true
    create_index "w", Address, %{w: 1}, unique: false, sparse: true
    create_index "i", Address, %{i: 1}, unique: false, sparse: true
    create_index "s", Address, %{s: 1}, unique: false
    create_index "s", Address, %{t: 1}, unique: false
    create_index "par", Address, %{par: 1}, unique: false, sparse: true
    create_index "coordinates_2dsphere", Address, %{coordinates: "2dsphere"}, unique: false
  end

  def dir_files dir do
    dir
    |> File.ls!()
    |> Stream.filter(& &1 |> String.contains?("tsv"))
    |> Stream.map(& dir <> &1)
  end

  def street_files(path), do: path |> dir_files
  def address_files(path), do: path |> dir_files

end
