defmodule AddressTooling.Address.AddressNameTest do

  use ExUnit.Case
  import AddressTooling.DataCase

  alias AddressTooling.Address.AddressName

  setup do
    Mongo.delete_many(:mongo, AddressName.collection(), %{})
    :ok
  end

  def example_address_name do
    %{
      _id: 1,
      n: "FLAT 1"
    }
  end

  test "collection" do
    assert AddressName.collection() == "address_names"
  end

  test "insert_many" do
    assert AddressName.count() == 0
    AddressName.insert_many( [example_address_name()] )
    assert AddressName.count() == 1
  end

  test "from_id" do
    address_name = example_address_name()
    insert_address_name address_name
    result = AddressName.from_id(address_name._id)
    assert result._id == address_name._id
  end

  test "from_name" do
    address_name = example_address_name()
    insert_address_name address_name
    result = AddressName.from_name(address_name.n) |> List.first
    assert result._id == address_name._id
  end

end
