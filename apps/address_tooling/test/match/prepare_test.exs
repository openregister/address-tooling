defmodule AddressTooling.Match.PrepareTest do

  use ExUnit.Case
  alias AddressTooling.Match.Prepare

  def lines() do
    [
      "Register Office",
      "High Street",
      "Townsville",
      "Kentshire"
    ]
  end

  def street_number_lines do
    [
      "5 High Street",
      "Townsville",
      "Kentshire"
    ]
  end

  test "address_words" do
    assert Prepare.address_words(lines()) ==
      ["Register","Office"]
  end

  test "address_words with street number" do
    assert Prepare.address_words(street_number_lines()) ==
      ["5","Townsville"]
  end

  test "address_lines" do
    assert Prepare.address_lines(lines()) ==
      lines()
  end

  test "address_lines with street number" do
    assert Prepare.address_lines(street_number_lines()) ==
      ["5","High Street","Townsville","Kentshire"]
  end
end
