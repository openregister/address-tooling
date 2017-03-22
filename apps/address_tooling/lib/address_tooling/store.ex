defmodule AddressTooling.Store.Collection do
  @type id :: integer
  @type item :: map
  @type filter :: map
  @type opts :: Keyword
  @type name :: String

  @doc """
  Return name of collection.
  """
  @callback collection :: String

  @doc """
  Filter from collection.
  """
  @callback from(filter, opts) :: String

  @doc """
  Return map with given id.
  """
  @callback from_id(id) :: Map

  @doc """
  Return map with given name.
  """
  @callback from_name(name) :: list

  @doc """
  Return expanded map.
  """
  @callback expand(item) :: Map

  @doc """
  Insert list of maps.
  """
  @callback insert_many(list) :: Map

  @doc """
  Count of collection.
  """
  @callback count() :: integer
end

defmodule AddressTooling.Store do

  defmacro __using__(opts) do
    quote do
      @behaviour AddressTooling.Store.Collection

      import AddressTooling.Store

      def collection, do: unquote(opts[:collection])

      def from filter, opts \\ [] do
        result = Mongo.find(:mongo, collection(), filter, opts)
        |> Enum.to_list
        |> Enum.map(&atomize_keys/1)

        if Keyword.get(opts, :expand, true) do
          result |> Enum.map(&expand/1)
        else
          result
        end
      end

      def from_id(id, opts \\ [])
      def from_id(nil, _), do: []
      def from_id("", _), do: []
      def from_id(id, opts) when is_binary(id), do: from_id(String.to_integer(id), opts)
      def from_id(id, opts) do
        from(%{_id: id}, Keyword.merge(opts, limit: 1))
        |> List.first
      end

      def insert_many([]), do: IO.puts "nothing to insert in #{collection()}"
      def insert_many list do
        Mongo.insert_many(:mongo, collection(), list, continue_on_error: true, timeout: 120_000)
        # IO.puts "#{count()} #{collection()} are persisted"
      end

      def count do
        {:ok, count} = Mongo.count(:mongo, collection(), nil, timeout: 120_000)
        count
      end

      def from_name(name), do: from %{n: name}

      def expand(map), do: map

      defoverridable [expand: 1, from_name: 1]

    end
  end

  def atomize(key) when is_atom(key), do: key
  def atomize(key) do
    key
    |> String.downcase()
    |> String.replace(~r"\W", " ")
    |> String.replace(~r"  +", " ")
    |> String.strip()
    |> String.replace(" ", "_")
    |> String.to_atom()
  end

  def atomize_keys map do
    keys = map |> Map.keys |> Enum.map(&atomize/1)
    keys |> Enum.zip(map |> Map.values) |> Map.new
  end

end
