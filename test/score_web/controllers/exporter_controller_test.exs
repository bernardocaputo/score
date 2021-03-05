defmodule Score.ExporterControllerTest do
  use ScoreWeb.ConnCase

  describe "export/2" do
    test "return success", %{conn: conn} do
      term = "ma"
      content = [%{map: "map"}] |> Jason.encode!()
      sort_options = %{sort_by: "", sort_order: ""} |> Jason.encode!()

      response =
        post(conn, Routes.exporter_path(conn, :export), %{
          "data" => %{"content" => content, "term" => term, "sort_options" => sort_options}
        })

      assert response.status == 200
    end
  end
end
