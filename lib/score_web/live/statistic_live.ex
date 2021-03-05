defmodule ScoreWeb.StatisticLive do
  @moduledoc """
    This module listen all events sent from statistics page
  """
  use ScoreWeb, :live_view
  alias Score.Statistics

  @default_per_page 20
  @default_page 1

  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(1000, self(), :timer)
    end

    pagination_options = %{page: @default_page, per_page: @default_per_page}
    sort_options = %{sort_order: "", sort_by: ""}

    new_socket =
      assign(socket,
        statistics: Statistics.list_nfl_rushing_statistics(pagination_options, sort_options),
        term: "",
        matches: [],
        page: pagination_options.page,
        per_page: pagination_options.per_page,
        sort_options: sort_options,
        timer: get_time()
      )

    {:ok, new_socket}
  end

  def handle_info(:timer, socket) do
    new_socket = assign(socket, :timer, get_time())
    {:noreply, new_socket}
  end

  defp get_time do
    {_erl_date, erl_time} = :calendar.local_time()
    {:ok, time} = Time.from_erl(erl_time)
    Time.to_string(time)
  end

  def handle_params(params, _url, socket) do
    sort_options = %{
      sort_by: params["sort_by"] || "",
      sort_order: params["sort_order"] || ""
    }

    pagination_options = %{page: socket.assigns.page, per_page: socket.assigns.per_page}

    statistics = statistics_to_use(params, sort_options, pagination_options)

    new_socket =
      socket
      |> assign(
        sort_options: sort_options,
        page: pagination_options.page,
        per_page: pagination_options.per_page,
        statistics: statistics
      )

    {:noreply, new_socket}
  end

  defp statistics_to_use(params, sort_options, pagination_options) do
    case params["term"] do
      term when term in ["", nil] ->
        Statistics.list_nfl_rushing_statistics(pagination_options, sort_options)

      term ->
        Statistics.player_search(term, sort_options, pagination_options)
    end
  end

  defp sort_link(socket, text, sort_options, term, page, per_page) do
    live_patch(text,
      to:
        Routes.live_path(
          socket,
          __MODULE__,
          sort_by: sort_options.sort_by,
          sort_order: toggle_sort_order(sort_options.sort_order),
          term: term,
          page: page,
          per_page: per_page
        )
    )
  end

  defp toggle_sort_order(sort_order) do
    case sort_order do
      "desc" -> "asc"
      _ -> "desc"
    end
  end

  def handle_event("load-more", _params, socket) do
    sort_options = %{
      sort_by: socket.assigns.sort_options.sort_by,
      sort_order: socket.assigns.sort_options.sort_order
    }

    pagination_options = %{page: socket.assigns.page, per_page: socket.assigns.per_page}

    new_socket =
      socket
      |> update(:per_page, &(&1 + @default_per_page))
      |> assign(
        statistics:
          Statistics.list_nfl_rushing_statistics(
            pagination_options,
            sort_options
          )
      )
      |> add_params_to_url()

    {:noreply, new_socket}
  end

  def handle_event("player-search", %{"term" => ""}, socket) do
    new_socket =
      socket
      |> clean_url()

    {:noreply, new_socket}
  end

  def handle_event("player-search", %{"term" => term}, socket) do
    new_socket =
      socket
      |> assign(:term, term)
      |> add_params_to_url()

    {:noreply, new_socket}
  end

  def handle_event("suggest-player", %{"term" => term}, socket) do
    new_socket =
      socket
      |> assign(:matches, Statistics.suggest_players(term))

    {:noreply, new_socket}
  end

  defp clean_url(socket) do
    socket
    |> push_patch(to: Routes.live_path(socket, __MODULE__))
  end

  defp add_params_to_url(socket) do
    socket
    |> push_patch(
      to:
        Routes.live_path(socket, __MODULE__,
          page: socket.assigns.page,
          per_page: socket.assigns.per_page,
          sort_by: socket.assigns.sort_options.sort_by,
          sort_order: socket.assigns.sort_options.sort_order,
          term: socket.assigns.term
        )
    )
  end
end
