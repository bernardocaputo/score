defmodule Score.Exporter do
  @moduledoc """
    This module is responsible for creating files that will be uploaded to the client
  """

  alias Score.Statistics

  @file_path "tmp"
  @file_name "report"

  @type csv_encoded :: String.t()
  @type file_path :: String.t()
  @type encoded_content :: String.t()
  @type encoded_sort_options :: String.t()

  @doc """
  Create a csv file by receiving an encoded map and return its path

  ## Examples
    iex> Exporter.create_csv_file(encoded_map)
      "tmp/report.csv"
  """
  @spec create_csv_file(csv_encoded()) :: {:ok, file_path()} | {:error, String.t()}
  def create_csv_file(data) do
    data
    |> map_to_csv()
    |> _create_csv_file()
  end

  @doc """
  Return the content that user want to export (filtered or complete)
  """
  @spec verify_content_to_be_exported(encoded_content, String.t(), encoded_sort_options) :: {:ok, [map()]}
  def verify_content_to_be_exported(content, term, sort_options) do
    content_to_be_exported =
      case term do
        "" ->
          sort_options_decoded = sort_options |> Jason.decode!() |> key_string_to_atom()
          Statistics.list_nfl_rushing_statistics(%{}, sort_options_decoded)

        _term ->
          content
          |> Jason.decode!()
      end

    {:ok, content_to_be_exported}
  end

  defp key_string_to_atom(map) do
    map
    |> Map.new(fn {key_string, value} -> {:"#{key_string}", value} end)
  end

  defp map_to_csv(data) do
    headers = data |> List.first() |> Map.keys()

    data
    |> CSV.encode(headers: headers)
    |> Enum.to_list()
  end

  defp _create_csv_file(csv_encoded) do
    with file_path <- "#{@file_path}/#{@file_name}.csv",
         :ok <- file_path |> Path.dirname() |> File.mkdir_p(),
         file <- File.open!(file_path, [:write, :utf8]) do
      Enum.each(csv_encoded, &IO.write(file, &1))
      File.close(file)

      {:ok, file_path}
    else
      _ -> {:error, "error creating csv file"}
    end
  end
end
