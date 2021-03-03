defmodule Score.Exporter do
  @moduledoc """
    This module is responsible for creating files that will be uploaded to the client
  """

  @file_path "tmp"
  @file_name "report"

  @type csv_encoded :: String.t()
  @type file_path :: String.t()

  @doc """
  Create a csv file by receiving an encoded map and return its path

  ## Examples
    iex> Exporter.create_csv_file(encoded_map)
      "tmp/report.csv"
  """
  @spec create_csv_file(csv_encoded()) :: {:ok, file_path()} | {:error, String.t()}
  def create_csv_file(data) do
    data
    |> Jason.decode!()
    |> map_to_csv()
    |> _create_csv_file()
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
