defmodule AddressTooling.Match.StreetTest do

  use ExUnit.Case
  import AddressTooling.DataCase
  alias AddressTooling.Match.Town
  alias AddressTooling.Match.Street
  alias AddressTooling.Address.Street, as: Streets

  def setup do
    AddressTooling.Match.TownTest.setup()
    Mongo.delete_many(:mongo, Streets.collection(), %{})
    insert_street(%{
      _id: 11,
      n: "HIGH STREET",
      t: 11
    })
    insert_street(%{
      _id: 12,
      n: "HIGH STREET",
      t: 12
    })
    insert_street(%{
      _id: 14,
      n: "HIGH STREET",
      t: 14
    })
    insert_street(%{
      _id: 15,
      n: "LOW STREET",
      t: 14
    })
    insert_street(%{
      _id: 16,
      n: "HIGH STREET",
      t: 16
    })
  end

  setup do
    setup()
    :ok
  end

  def lines() do
    ["5","High Street","Townsville","Kentshire"]
  end

  test "match streets for lines with towns" do
    towns = Town.match(lines())
    assert Street.match(lines(), towns)
            |> Enum.map(& &1._id) == [12, 14, 11]
  end
end
