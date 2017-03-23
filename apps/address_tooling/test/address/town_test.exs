defmodule AddressTooling.Address.TownTest do

  use ExUnit.Case

  alias AddressTooling.Address.Town

  setup do
    Mongo.delete_many(:mongo, Town.collection(), %{})
    :ok
  end

  def example_town do
    %{
      _id: 11,
      area: "LIVERPOOL",
      n: "LIVERPOOL"
    }
  end

  test "collection" do
    assert Town.collection() == "towns"
  end

  test "insert_many" do
    assert Town.count() == 0
    Town.insert_many( [example_town()] )
    assert Town.count() == 1
  end

  test "from_id" do
    town = example_town()
    Town.insert_many( [town] )
    result = Town.from_id(town._id)
    assert result._id == town._id
  end

  test "from_name" do
    town = example_town()
    Town.insert_many( [town] )
    result = Town.from_name(town.n) |> List.first
    assert result._id == town._id
  end

end
