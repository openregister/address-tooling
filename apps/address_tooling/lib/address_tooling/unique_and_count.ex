defmodule UniqueAndCount do

  def accumulate_count(item, map) do
    count = (map |> Map.get(item, 0)) + 1
    map = map |> Map.put(item, count)
    {[map], map}
  end

  def flatten_count(nil), do: []
  def flatten_count(enum), do: enum |> Enum.map(& &1 |> Tuple.to_list |> List.flatten)

  def headers headers do
    [ headers ]
    |> CSV.encode(separator: ?\t, delimiter: "\n")
    |> Enum.each(&IO.write/1)
  end

  def unique_and_count stream do
    stream
    |> Stream.transform(%{}, fn (item, map) -> accumulate_count(item, map) end)
    |> Stream.take(-1)
    |> Enum.at(0)
    |> flatten_count
    |> Enum.sort(& List.last(&1) >= List.last(&2))
    |> Enum.map(& &1 |> Enum.join("\t"))
    |> Enum.each(&IO.puts/1)
  end

  def strip_dot(nil), do: nil
  def strip_dot(text), do: text |> String.replace(".", "")

  def town_admin([town, administrative_area]), do: town_admin(town, administrative_area)
  def town_admin([town]), do: town
  def town_admin(town, administrative_area) when town == administrative_area, do: town
  def town_admin(town, administrative_area), do: "#{town}|#{administrative_area}"

  def unique_town_admin file do
    File.stream!(file)
    |> DataMorph.structs_from_tsv(UniqueAndCount, Street)
    |> Stream.map(& town_admin(strip_dot(&1.town), strip_dot(&1.administrative_area)))
  end

  def street_files(directory \\ "../addressbase-data/cache/street/") do
    File.ls!(directory)
    |> Stream.filter(& &1 |> String.contains?("tsv"))
    |> Stream.map(& "../addressbase-data/cache/street/" <> &1)
  end

  def unique_town_admin_from_dir(directory) do
    headers ["town-administrative-area", "count"]
    street_files(directory)
    |> Stream.flat_map(& unique_town_admin(&1))
    |> unique_and_count
  end

end
