defmodule AddressTooling.Address.StreetTest do

  use ExUnit.Case

  alias AddressTooling.Address.Street

  setup do
    Mongo.delete_many(:mongo, Street.collection(), %{})
    :ok
  end

  def example_street do
    %{
      _id: 23602321,
      c: 4310,
      n: "HIGHER LANE",
      t: 11
    }
  end

  test "collection" do
    assert Street.collection() == "streets"
  end

  test "insert_many" do
    assert Street.count() == 0
    Street.insert_many( [example_street()] )
    assert Street.count() == 1
  end

  test "from_id" do
    street = example_street()
    Street.insert_many( [street] )
    result = Street.from_id(street._id)
    assert result._id == street._id
  end

  test "from_name" do
    street = example_street()
    Street.insert_many( [street] )
    result = Street.from_name(street.n) |> List.first
    assert result._id == street._id
  end

end
