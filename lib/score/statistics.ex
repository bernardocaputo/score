defmodule Score.Statistics do
  @moduledoc """
  This module contains statistic functions from players
  """
  @file_path "./assets/static/json/rushing.json"
  @external_resource @file_path
  @json_data @file_path
             |> File.read!()
             |> Jason.decode!()
             |> Stream.with_index()
             |> Enum.map(fn {x, index} ->
               x |> Map.put("Id", index + 1)
             end)

  @type statistic() :: map()
  @type sort_options() :: map()
  @type pagination_options() :: map()

  @doc """
  Return NFL players statistics

  ## Examples

      iex> Statistics.get_nfl_rushing_statistics
      [
        %{
          "1st" => 3,
          "1st%" => 25,
          "20+" => 0,
          "40+" => 0,
          "Att" => 12,
          "Att/G" => 4,
          "Avg" => 3.3,
          "FUM" => 0,
          "Lng" => "17",
          "Player" => "Jamaal Charles",
          "Pos" => "RB",
          "TD" => 1,
          "Team" => "KC",
          "Yds" => 40,
          "Yds/G" => 13.3
        },
        %{...}
      ]
  """
  @spec get_nfl_rushing_statistics() :: list(statistic())
  def get_nfl_rushing_statistics do
    @json_data
  end

  @doc """
  Return a paginated and sorted list of NFL players statistics
  """
  @spec list_nfl_rushing_statistics(pagination_options(), sort_options()) :: list(statistic())
  def list_nfl_rushing_statistics(pagination_options, sort_options) do
    get_nfl_rushing_statistics()
    |> sort_result(sort_options)
    |> paginate_result(pagination_options)
  end

  @doc """
  Suggest player's name when filtering
  """
  @spec suggest_players(String.t()) :: list(String.t())
  def suggest_players(""), do: []

  def suggest_players(term) do
    term_downcased = String.downcase(term)

    get_nfl_rushing_statistics()
    |> Stream.filter(fn %{"Player" => name} ->
      name_downcased = String.downcase(name)
      String.starts_with?(name_downcased, term_downcased)
    end)
    |> Stream.map(fn %{"Player" => name} -> name end)
    |> Enum.take(10)
  end

  @doc """
  Filter statistics by given term
  """
  @spec player_search(String.t(), sort_options(), pagination_options())  :: list(statistic())
  def player_search(term, sort_options, pagination_options) do
    term_downcased = String.downcase(term)

    get_nfl_rushing_statistics()
    |> Stream.filter(fn %{"Player" => name} ->
      name_downcased = String.downcase(name)
      String.contains?(name_downcased, term_downcased)
    end)
    |> sort_result(sort_options)
    |> paginate_result(pagination_options)
  end

  defp sort_result(result, map) when map == %{}, do: result

  defp sort_result(result, %{sort_by: _sort_by, sort_order: ""}), do: result

  defp sort_result(result, %{sort_by: sort_by} = sort_options) do
    result
    |> format_data(sort_by)
    |> _sort_result(sort_options)
  end

  defp _sort_result(result, %{sort_by: sort_by, sort_order: sort_order}) when sort_by in ["Yds", "TD"] do
    Enum.sort_by(result, & &1["#{sort_by}"], :"#{sort_order}")
  end

  defp _sort_result(result, %{sort_by: sort_by = "Lng", sort_order: sort_order}) do
    result
    |> Enum.sort_by(& &1[sort_by] |> Tuple.to_list |> List.first, :"#{sort_order}")
    |> Enum.map(fn %{^sort_by => {int, string}} = statistic ->
      Map.put(statistic, sort_by, Integer.to_string(int) <> string)
    end)


  end

  defp paginate_result(data, options) when options == %{}, do: data

  defp paginate_result(data, %{page: page, per_page: per_page}) do
    offset = (page - 1) * per_page

    index = page * per_page - 1

    data
    |> Enum.slice(offset..index)
  end

  defp format_data(data, "Yds") do
    data
    |> Stream.map(fn %{"Yds" => yds} = statistic ->
      new_yds =
        try do
          yds |> String.replace(",", "") |> String.to_integer()
        rescue
          _ ->
            yds
        end

      Map.put(statistic, "Yds", new_yds)
    end)
  end

  defp format_data(data, "Lng") do
    data
    |> Stream.map(fn %{"Lng" => lng} = x ->
      new_lng =
        try do
          lng |> Integer.to_string()
        rescue
          _ ->
            lng
        end
        |> Integer.parse()

      Map.put(x, "Lng", new_lng)
    end)
  end

  defp format_data(data, _), do: data
end
