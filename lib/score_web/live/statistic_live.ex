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
        timer: get_time()
      )

    {:ok, new_socket}
  end

  def handle_info(:timer, socket) do
    new_socket = assign(socket, :timer, get_time())
    {:noreply, new_socket}
  end

  defp get_time() do
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
      <input placeholder="Player Name" autocomplete="off" phx-debounce="1000" type="text" name="term" value="<%= @term %>" list="matches"><%= @term %></input>
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
          <th>Yds</th>
          <th>Yds/G</th>
          <th>TD</th>
          <th>Lng</th>
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

  def handle_event("player-search", %{"term" => term}, %{assigns: %{term: old_term}} = socket) do
    new_socket =
      socket
      |> update(:statistics, &Statistics.filter_player_name(&1, old_term, term))
      |> assign(:term, term)

    {:noreply, new_socket}
  end

  def handle_event("suggest-player", %{"term" => term}, socket) do
    new_socket =
      socket
      |> assign(:matches, Statistics.suggest_players(term))

    {:noreply, new_socket}
  end
end
