defmodule AddressTooling.Match.Street do

  alias AddressTooling.Address.Street, as: Streets
  alias AddressTooling.Match.Prepare

  def match_without_number? line, street do
    (line
    |> String.replace(Prepare.street_number_pattern(), "")) == street.n
  end

  def street_match? street, lines do
    match = lines
      |> Enum.any?(& &1 == street.n)

    case match do
      false ->
        lines
        |> Enum.any?(& &1 |> match_without_number?(street))
      _ -> match
    end
  end

  def streets town do
    Streets.from_town_id(town._id)
  end

  def match lines, towns do
    lines = lines |> Enum.map(&String.upcase/1)
    towns
    |> Enum.flat_map(&streets/1)
    |> Enum.filter(& &1 |> street_match?(lines))
  end
end
