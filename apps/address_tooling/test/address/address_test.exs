defmodule AddressTooling.Address.AddressTest do

  use ExUnit.Case

  alias AddressTooling.Address.Address
  alias AddressTooling.Address.AddressName

  setup do
    Mongo.delete_many(:mongo, Address.collection(), %{})
    :ok
  end

  def example_address do
    %{
      _id: 38076557,
      c: 4310,
      coordinates: [-2.9357105, 53.4618475],
      n: "HM PRISON ALTCOURSE",
      p: "L9 7LH",
      s: 23602321,
      t: 11
    }
  end

  def example_address_with_address_name address_name_id do
    %{
      _id: 38076557,
      a: address_name_id
    }
  end

  test "collection" do
    assert Address.collection() == "addresses"
  end

  test "insert_many" do
    assert Address.count() == 0
    Address.insert_many( [example_address()] )
    assert Address.count() == 1
  end

  test "from_id" do
    address = example_address()
    Address.insert_many( [address] )
    result = Address.from_id(address._id)
    assert result._id == address._id
  end

  test "from_name" do
    address = example_address()
    Address.insert_many( [address] )
    result = Address.from_name(address.n) |> List.first
    assert result._id == address._id
  end

  test "from_name expands linked address name" do
    address_name = AddressTooling.Address.AddressNameTest.example_address_name()
    address = example_address_with_address_name(address_name._id)

    AddressName.insert_many( [address_name] )
    Address.insert_many( [address] )
    result = Address.from_name(address_name.n) |> List.first
    assert result.n == address_name.n
  end

end
