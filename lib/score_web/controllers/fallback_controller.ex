defmodule ScoreWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use ScoreWeb, :controller

  def call(conn, {:error, reason}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(ScoreWeb.ErrorView)
    |> json(reason)
  end
end
