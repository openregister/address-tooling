defmodule AddressTooling.Match.AddressTest do

  use ExUnit.Case
  import AddressTooling.DataCase
  alias AddressTooling.Match.Town
  alias AddressTooling.Match.Street
  alias AddressTooling.Match.Address
  alias AddressTooling.Address.Address, as: Addresses

  setup do
    AddressTooling.Match.StreetTest.setup()
    Mongo.delete_many(:mongo, Addresses.collection(), %{})
    insert_address(%{
      _id: 1,
      i: 5,
      s: 11,
      t: 11
    })
    insert_address(%{
      _id: 2,
      n: "UNIT 5",
      s: 11,
      t: 11
    })
    insert_address(%{
      _id: 3,
      i: 5,
      s: 12,
      t: 12
    })
    :ok
  end

  def lines() do
    ["5","High Street","Townsville","Kentshire"]
  end

  def words() do
    ["5","Townsville"]
  end

  test "match addresses for lines with streets" do
    towns = Town.match(lines())
    streets = Street.match(lines(), towns)
    assert Address.match(lines(), words(), streets) == [
      [
        19,
        %{_id: 3, i: 5, locality: nil, n: "5", s: 12, street: "HIGH STREET", t: 12, town: "TOWNSVILLE"}
      ],
      [
        15,
        %{_id: 1, i: 5, locality: nil, n: "5", s: 11, street: "HIGH STREET", t: 11, town: "SMALLSVILLE"}
      ],
      [
        8,
        %{_id: 2, locality: nil, n: "UNIT 5", s: 11, street: "HIGH STREET", t: 11, town: "SMALLSVILLE"}
      ]
    ]
  end
end
