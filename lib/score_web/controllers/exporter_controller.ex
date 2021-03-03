defmodule ScoreWeb.ExporterController do
  use ScoreWeb, :controller

  alias Score.Exporter

  def export(conn, %{"data" => %{"content" => content}}) do
    with {:ok, file_path} <- Exporter.create_csv_file(content),
         file_name <- Path.basename(file_path) do
      conn
      |> put_resp_content_type("text/csv")
      |> put_resp_header("content-disposition", "attachment; filename=\"#{file_name}\"")
      |> send_file(200, file_path)
    end
  end
end
