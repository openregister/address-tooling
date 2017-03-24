defmodule AddressTooling.Match.Prepare do

  @street_number ~r/^([0-9]+[A-Za-z]?|[0-9]+-[0-9]+) +/

  def street_number_pattern do
    @street_number
  end

  def number_and_street line do
    if line |> String.match?(@street_number) do
      [[street_number_prefix, street_number]] = Regex.scan(street_number_pattern(), line)
      street = line |> String.replace(street_number_prefix, "")
      [street_number, street]
    else
      [nil, line]
    end
  end

  def street_number_or_line line do
    case number_and_street line do
      [nil, _] -> line
      [street_number, _street] -> street_number
    end
  end

  def split_street_number line do
    case number_and_street line do
      [nil, _] -> [line]
      [street_number, street] -> [street_number, street]
    end
  end

  def address_lines lines do
    lines
    |> Enum.reject(&is_nil/1)
    |> Enum.flat_map(&split_street_number/1)
    |> Enum.map(& &1 |> String.replace("(","") |> String.replace(")","") |> String.replace("`","") |> String.replace(~r/(\d) - (\d)/, "\\1-\\2"))
    |> Enum.reject(& &1 |> String.length == 0)
  end

  def address_words lines do
    lines
    |> Enum.take(2)
    |> Enum.map(&street_number_or_line/1)
    |> Enum.reject(& &1 |> String.upcase |> String.match?(~r"STREET| ROAD| LANE"))
    |> Enum.flat_map(& &1 |> String.replace("(","") |> String.replace(")","") |> String.split(" "))
    |> Enum.reject(& &1 == "The")
  end

end
