defmodule AddressTooling.Match.Score do

  alias AddressTooling.Match.Prepare

  def remove_street(address_words, nil), do: address_words
  def remove_street address_words, street do
    address_words
    |> Enum.join(" ")
    |> String.replace(street,"")
    |> String.trim
    |> String.split(" ")
  end

  def words_score address, address_words do
    address_words = address_words
      |> Enum.map(&String.upcase/1)
      |> remove_street(address.street)

    exact_matching = address_words \
      |> Enum.filter(& address.n == &1) \
      |> Enum.count

    matching = address_words \
      |> Enum.filter(&
        if(&1 |> String.match?(~r"^OFFICE$")) do
          false
        else
          address.n |> String.contains?(&1)
        end
      ) \
      |> Enum.count

    non_matching = address.n \
      |> String.split(~r/ |\//) \
      |> Enum.reject(& address_words |> Enum.any?(fn x ->
        (&1 == x) ||
        (&1 == "STREET") ||
        (&1 == "AND") ||
        (String.length(&1) < 2 )
      end) ) \
      |> Enum.count

    ((exact_matching + matching) * 2) - non_matching
  end

  def line_match? address_with_street, line do
    case Prepare.number_and_street line do
      [nil, _] ->
        address_with_street |> String.match?(~r/(^#{line})|( #{line})/)
      [street_number, street] ->
        (address_with_street |> String.match?(~r/(^#{street_number})|( #{street_number})/))
        && (address_with_street |> String.match?(~r/#{street}/))
    end
  end

  def line_exact_match? address_with_street, address, line do
    case Prepare.number_and_street line do
      [nil, _] ->
        (line == address_with_street) || (line == address.n)
      [street_number, _street] ->
        (line == address_with_street) || (street_number == address.n)
    end
  end

  def lines_score address, address_lines do
    address_lines = address_lines |> Enum.map(& &1 |> String.upcase |> String.replace("BUILDINGS","BUILDING") )

    address_with_street_locality = [address.n, address.street, address.locality] \
      |> Enum.reject(&is_nil/1) \
      |> Enum.map(& &1 |> String.replace("BUILDINGS","BUILDING")) \
      |> Enum.join(" ")

    address_with_street = [address.n, address.street] \
      |> Enum.reject(&is_nil/1) \
      |> Enum.map(& &1 |> String.replace("BUILDINGS","BUILDING")) \
      |> Enum.join(" ")

    score = address_lines \
      |> Enum.filter(& line_match?(address_with_street, &1) || line_match?(address_with_street_locality, &1)) \
      |> Enum.count
    exact_score = address_lines \
      |> Enum.filter(& line_exact_match?(address_with_street, address, &1) || line_exact_match?(address_with_street_locality, address, &1) ) \
      |> Enum.count

    ((exact_score * 2) + score) * 2
  end

  def de_welsh(nil), do: nil
  def de_welsh text do
    text
    |> String.replace("WRECSAM","WREXHAM")
    |> String.replace("CAERDYDD","CARDIFF")
  end

  def town_score(_address, nil), do: 0
  def town_score address, line do
    address_town = address.town |> de_welsh()
    case address_town do
      nil -> 0
      town ->
        line = line |> String.upcase |> de_welsh()
        if town == line do
          4
        else
          if town |> String.match?(~r"^#{line}\|")  do
            2
          else
            0
          end
        end
    end
  end

  def town_score address, line1, line2, line3 do
    [
      address |> town_score(line1),
      address |> town_score(line2),
      address |> town_score(line3)
    ] |> Enum.max
  end

  def area_score address, area, line do
    case address.town |> de_welsh() do
      nil -> 0
      town ->
        text = RegisterOfficeData.Towns.town_regex(area, line |> String.upcase |> de_welsh() )
        regex = Regex.compile!(text)
        boost = if Regex.match?(regex, town) do
                  4
                else
                  0
                end
        if town |> String.match?(~r/^#{area}$/) do
          2 + boost
        else
          if town |> String.match?(~r/\|#{area}/) do
            4 + boost
          else
            boost
          end
        end
    end
  end

  def area_score area, address, last_line, second_last_line do
    address
    |> area_score(area, last_line)
    |> max( area_score(address, area, second_last_line) )
  end

  def stop_words do
    [
      "FLAT ",
      "SERVICE, SITE OF",
      "LAND NORTH",
      "LAND SOUTH",
      "LAND EAST",
      "LAND WEST",
      "LAND AT",
      "LAND ADJ",
      "CAR PARK",
      "ELECTRICITY SUB",
      "POLICE",
      "THE OLD ",
      "SITE OF FORMER ASHFORD LIBRARY",
      "OFFICERS CLUB",
      "WINDFARM",
      "SMOKERY",
      "ENTRANCE GATE",
      "LIBRARY"
    ]
  end

  def stop_words_score address do
    if stop_words() |> Enum.any?(& address.n |> String.contains?(&1)) do
      -5
    else
      0
    end
  end

  def street_score address, streets do
    if streets |> Enum.any?(& &1._id == address.s) do
      3
    else
      0
    end
  end

  def address_score address, words, lines, areas, streets do
    case address do
      %{n: _} ->
        street_score = address |> street_score(streets)
        words_score = address |> words_score(words)
        lines_score = address |> lines_score(lines)

        last_line = lines |> List.last
        {second_last_line, _} = lines |> List.pop_at(-2)
        {third_last_line, _} = lines |> List.pop_at(-3)

        town_score = town_score(address, third_last_line, second_last_line, last_line)

        area_score = case areas do
                       [] -> 0
                       _ ->
                         areas
                         |> Enum.map(& &1 |> area_score(address, last_line, second_last_line))
                         |> Enum.max
                     end

        end_date_score = case address |> Map.get(:e) do
                           nil -> 0
                           _ -> -1
                         end
        stop_score = stop_words_score address
        total = words_score + lines_score + area_score + end_date_score +
          street_score + town_score + stop_score
        IO.puts inspect(address)
        IO.puts "words_score #{words_score}"
        IO.puts "lines_score #{lines_score}"
        IO.puts "street_score #{street_score}"
        IO.puts "town_score #{town_score}"
        IO.puts "area_score #{area_score}"
        IO.puts "end_date_score #{end_date_score}"
        IO.puts "stop_words_score #{stop_score}"
        IO.puts "total #{total}"
        IO.puts ""
        total
      _ -> -100
    end
  end

end
