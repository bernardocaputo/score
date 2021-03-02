defmodule Score.Statistics do
  @moduledoc """
  This module contains statistic functions from players
  """
  @json_path "./assets/static/json/rushing.json"
  @json_data @json_path |> File.read!() |> Jason.decode!()

  @type statistic() :: map()

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

  def player_search(term, data \\ get_nfl_rushing_statistics(), options \\ %{}) do
    term_downcased = String.downcase(term)

    data
    |> Stream.filter(fn %{"Player" => name} ->
      name_downcased = String.downcase(name)
      String.contains?(name_downcased, term_downcased)
    end)
    |> sort_result(options)
  end

  defp sort_result(result, options) when options == %{}, do: result

  defp sort_result(result, %{sort_by: sort_by, sort_order: sort_order}) do
    result
    |> format_data(sort_by)
    |> Enum.sort_by(& &1["#{sort_by}"], :"#{sort_order}")
  end

  defp format_data(data, "Yds") do
    data
    |> Enum.map(fn %{"Yds" => yds} = x ->
      new_yds =
        try do
          yds |> String.replace(",", "") |> String.to_integer()
        rescue
          _ ->
            yds
        end

      Map.put(x, "Yds", new_yds)
    end)
  end

  # TO DO How to handle Lng sort?
  # defp format_data(data, "Lng") do
  # end

  defp format_data(data, _), do: data
end
