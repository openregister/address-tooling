defmodule AddressTooling.Match.Town do

  alias AddressTooling.Address.Town, as: Towns

  def match line1, line2 do
    town = line1 |> String.upcase
    area = line2 |> String.upcase

    towns = if town == area do
      Towns.from_name_area(town, area)
    else
      if town |> String.match?(~r"STREET| ROAD| LANE") do
        Towns.from_name(area) ++ Towns.from_area(area)
      else
        if town |> String.contains?(" #{area}") do
          town_alone = town |> String.replace(" #{area}","") |> String.trim()
          if town_alone |> String.length > 0 do
            Towns.from_name_area(town, area) ++
            Towns.from_name_area(town_alone, area)
          else
            Towns.from_name_area(town, area)
          end
        else
          Towns.from_name_area(town, area) ++
          Towns.from_name_area(town, town) ++
          Towns.from_name_area(area, area) ++
          Towns.from_name(area) ++
          Towns.from_name(town) ++
          Towns.from_area(area)
        end
      end
    end
    towns
  end

  def match lines do
    case (lines |> Enum.count) do
      1 -> [:one]
      _ ->
        {line0,_} = lines |> List.pop_at(-3)
        {line1,_} = lines |> List.pop_at(-2)
        {line2,_} = lines |> List.pop_at(-1)
        match(line1, line2) ++
        match(line0, line2)
        |> Enum.uniq
    end
  end
end
