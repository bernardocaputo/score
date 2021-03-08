defmodule Score.StatisticsTest do
  use Score.DataCase

  alias Score.Statistics

  describe "get_nfl_rushing_statistics/0" do
    test "return json file" do
      statistics = Statistics.get_nfl_rushing_statistics()
      assert is_list(statistics)
      assert length(statistics) == 326
    end
  end

  describe "list_nfl_rushing_statistics/2" do
    test "should paginate list" do
      statistics_one = Statistics.list_nfl_rushing_statistics(%{page: "1", per_page: "2"}, %{})
      statistics_two = Statistics.list_nfl_rushing_statistics(%{page: "2", per_page: "2"}, %{})
      assert length(statistics_one) == 2
      assert length(statistics_two) == 2
      assert statistics_one != statistics_two
    end

    test "should sort list - Yds" do
      {min_yds, max_yds} = Statistics.get_nfl_rushing_statistics() |> get_min_max_from_key("Yds")

      statistics_max =
        Statistics.list_nfl_rushing_statistics(%{}, %{sort_by: "Yds", sort_order: "desc"})
        |> List.first()

      statistics_min =
        Statistics.list_nfl_rushing_statistics(%{}, %{sort_by: "Yds", sort_order: "asc"})
        |> List.first()

      assert statistics_max["Yds"] == max_yds
      assert statistics_min["Yds"] == min_yds
    end

    test "should sort list - TD" do
      {min_td, max_td} = Statistics.get_nfl_rushing_statistics() |> get_min_max_from_key("TD")

      statistics_max =
        Statistics.list_nfl_rushing_statistics(%{}, %{sort_by: "TD", sort_order: "desc"})
        |> List.first()

      statistics_min =
        Statistics.list_nfl_rushing_statistics(%{}, %{sort_by: "TD", sort_order: "asc"})
        |> List.first()

      assert statistics_max["TD"] == max_td
      assert statistics_min["TD"] == min_td
    end

    test "should sort list - Lng" do
      {min_lng, max_lng} = Statistics.get_nfl_rushing_statistics() |> get_min_max_from_key("Lng")

      {statistics_max, _} =
        Statistics.list_nfl_rushing_statistics(%{}, %{sort_by: "Lng", sort_order: "desc"})
        |> List.first()
        |> Map.get("Lng")
        |> Integer.parse()

      {statistics_min, _} =
        Statistics.list_nfl_rushing_statistics(%{}, %{sort_by: "Lng", sort_order: "asc"})
        |> List.first()
        |> Map.get("Lng")
        |> Integer.parse()

      assert statistics_max == max_lng
      assert statistics_min == min_lng
    end
  end

  describe "suggest_players/1" do
    test "return empty list when term is empty string" do
      assert [] == Statistics.suggest_players("")
    end

    test "return max 10 player suggestions" do
      term = "A"

      results =
        Statistics.get_nfl_rushing_statistics()
        |> Enum.filter(fn %{"Player" => player} -> String.starts_with?(player, term) end)

      suggestions = Statistics.suggest_players(term)

      assert suggestions > 10
      assert min(10, length(results)) == length(suggestions)
    end
  end

  describe "player_search/3" do
    test "return filtered search" do
      term = "ma"

      result =
        Statistics.get_nfl_rushing_statistics()
        |> Enum.filter(fn %{"Player" => player} ->
          downcase_player = String.downcase(player)
          String.contains?(downcase_player, term)
        end)

      filtered_search = Statistics.player_search(term, %{}, %{})

      assert filtered_search
             |> Enum.all?(fn %{"Player" => player} ->
               downcase_player = String.downcase(player)
               String.contains?(downcase_player, term)
             end)

      assert length(result) == length(filtered_search)
    end
  end

  defp get_min_max_from_key(statistics, "Lng") do
    statistics
    |> Stream.map(fn %{"Lng" => lng} = x ->
      new_lng = lng |> integer_to_string() |> Integer.parse()
      Map.put(x, "Lng", new_lng)
    end)
    |> Enum.map(&(&1["Lng"] |> Tuple.to_list() |> List.first()))
    |> Enum.min_max()
  end

  defp get_min_max_from_key(statistics, key) do
    statistics
    |> Stream.map(fn %{^key => value} ->
      string_to_integer(value)
    end)
    |> Enum.min_max()
  end

  defp string_to_integer(maybe_string) do
    maybe_string
    |> String.replace(",", "")
    |> String.to_integer()
  rescue
    _ -> maybe_string
  end

  defp integer_to_string(maybe_integer) do
    maybe_integer
    |> Integer.to_string()
  rescue
    _ -> maybe_integer
  end
end
