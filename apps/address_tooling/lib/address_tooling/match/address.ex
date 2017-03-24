defmodule AddressTooling.Match.Address do

  alias AddressTooling.Address.Address, as: Addresses
  alias AddressTooling.Match.Score

  def addresses street do
    Addresses.from_street_id street._id, expand: true
  end

  def add_child_addresses address do
    if address |> Map.has_key?(:e) do # end-date
      [address, Address.from_parent_id(address._id)]
    else
      [address]
    end
  end

  def match_addresses([], _words, _lines, _streets), do: []
  def match_addresses addresses, words, lines, streets do
    addresses
    |> Enum.flat_map(&add_child_addresses/1)
    |> Enum.map(& [&1 |> Score.address_score(words, lines, [], streets), &1] )
    |> Enum.reject(& (&1 |> List.first) == 0 )
    |> Enum.sort_by(& List.first(&1) * -1)
    |> Enum.take(6)
  end


  def match lines, words, streets do
    addresses = streets |> Enum.flat_map(&addresses/1)

    match_addresses(addresses, words, lines, streets)
  end
end
