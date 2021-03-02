defmodule ScoreWeb.StatisticLive do
  @moduledoc """
    This module listen all events sent from statistics page
  """
  use ScoreWeb, :live_view
  alias Score.Statistics

  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(1000, self(), :timer)
    end

    new_socket =
      assign(socket,
        statistics: Statistics.get_nfl_rushing_statistics(),
        term: "",
        matches: [],
        sort_options: %{sort_order: "asc", sort_by: nil},
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

  def render(assigns) do
    ~L"""
    <h1> NFL Players Statistics </h1>
    <p> <%= @timer %> </p>
    <form autocomplete="off" phx-submit="player-search" phx-change="suggest-player">
      <span>Filter By Player</span>
      <input placeholder="Player Name" autocomplete="off" phx-debounce="1000" type="text" name="term" value="<%= @term %>" list="matches"></input>
      <button type="submit">Search</button>
    </form>

    <datalist id="matches">
      <%= for match <- @matches do %>
        <option value="<%= match %>"><%= match %></option>
      <% end %>
    </datalist>

    <table>
      <thead>
        <tr>
          <th>Player</th>
          <th>Team</th>
          <th>Pos</th>
          <th>Att</th>
          <th>Att/G</th>
          <th>Avg</th>
          <th>
            <%= sort_link(@socket, "Yds", %{@sort_options | sort_by: "Yds"}, @term) %>
          </th>
          <th>Yds/G</th>
          <th>
            <%= sort_link(@socket, "TD", %{@sort_options | sort_by: "TD"}, @term) %>
          </th>
          <th>
          <%= sort_link(@socket, "Lng", %{@sort_options | sort_by: "Lng"}, @term) %>
          </th>
          <th>1st%</th>
          <th>1st</th>
          <th>20</th>
          <th>40</th>
          <th>FUM</th>
        </tr>
      </thead>
      <tbody>
        <%= for statistic <- @statistics do %>
          <tr class="active-row">
            <td> <%= statistic["Player"] %> </td>
            <td> <%= statistic["Team"] %> </td>
            <td> <%= statistic["Pos"] %> </td>
            <td> <%= statistic["Att"] %> </td>
            <td> <%= statistic["Att/G"] %> </td>
            <td> <%= statistic["Avg"] %> </td>
            <td> <%= statistic["Yds"] %> </td>
            <td> <%= statistic["Yds/G"] %> </td>
            <td> <%= statistic["TD"] %> </td>
            <td> <%= statistic["Lng"] %> </td>
            <td> <%= statistic["1st%"] %> </td>
            <td> <%= statistic["1st"] %> </td>
            <td> <%= statistic["20+"] %> </td>
            <td> <%= statistic["40+"] %> </td>
            <td> <%= statistic["FUM"] %> </td>
          </tr>
        <% end %>
      </tbody>
    </table>
    """
  end

  def handle_params(
        %{"sort_by" => sort_by, "sort_order" => sort_order} = params,
        _url,
        %{assigns: %{term: term, statistics: statistics}} = socket
      ) do
    sort_options = %{sort_by: sort_by, sort_order: toggle_sort_order(sort_order)}

    new_socket =
      socket
      |> assign(:sort_options, sort_options)
      |> assign(:statistics, Statistics.player_search(term, statistics, sort_options))

    {:noreply, new_socket}
  end

  defp toggle_sort_order("asc"), do: "desc"
  defp toggle_sort_order("desc"), do: "asc"

  defp sort_link(socket, text, sort_options, term) do
    live_patch(text,
      to:
        Routes.live_path(
          socket,
          __MODULE__,
          sort_by: sort_options.sort_by,
          sort_order: sort_options.sort_order,
          term: term
        )
    )
  end

  def handle_params(_, _, socket), do: {:noreply, socket}

  def handle_event("player-search", %{"term" => term} = params, socket) do
    new_socket =
      socket
      |> assign(:statistics, Statistics.player_search(term))
      |> assign(:term, term)
      |> push_patch(to: Routes.live_path(socket, __MODULE__, term: term))

    {:noreply, new_socket}
  end

  def handle_event("suggest-player", %{"term" => ""}, socket) do
    new_socket =
      socket
      |> assign(:statistics, Statistics.get_nfl_rushing_statistics())

    {:noreply, new_socket}
  end

  def handle_event("suggest-player", %{"term" => term}, socket) do
    new_socket =
      socket
      |> assign(:matches, Statistics.suggest_players(term))

    {:noreply, new_socket}
  end
end
