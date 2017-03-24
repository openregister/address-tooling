defmodule AddressTooling.Match.TownTest do

  use ExUnit.Case
  import AddressTooling.DataCase
  alias AddressTooling.Match.Town
  alias AddressTooling.Address.Town, as: Towns

  setup do
    Mongo.delete_many(:mongo, Towns.collection(), %{})
    insert_town(%{
      _id: 11,
      n: "SMALLSVILLE",
      area: "KENTSHIRE"
    })
    insert_town(%{
      _id: 12,
      n: "TOWNSVILLE",
      area: "KENTSHIRE"
    })
    insert_town(%{
      _id: 13,
      n: "",
      area: "KENTSHIRE"
    })
    insert_town(%{
      _id: 14,
      n: "TOWNSVILLE",
      area: "BATHSHIRE"
    })
    :ok
  end

  def lines() do
    ["5","High Street","Townsville","Kentshire"]
  end

  test "match lines" do
    assert Town.match(lines())
           |> Enum.map(& &1._id) == [12, 14, 11, 13]
  end
end
