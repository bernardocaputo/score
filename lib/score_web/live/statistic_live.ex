defmodule ScoreWeb.StatisticLive do
  @moduledoc """
    This module listen all events sent from statistics page
  """
  use ScoreWeb, :live_view
  alias Score.Statistics

  def mount(_params, _session, socket) do
    new_socket = assign(socket, statistics: Statistics.get_nfl_rushing_statistics(), term: "")
    {:ok, new_socket}
  end

  def render(assigns) do
    ~L"""
    <h1> NFL Players Statistics </h1>
    <form autocomplete="off" phx-change="player_name">
      <span>Filter By Player</span>
      <input name="term" value="<%= @term %>"> </input>
    </form>
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

  def handle_event("player_name", %{"term" => term}, %{assigns: %{term: old_term}} = socket) do
    new_socket =
      socket
      |> update(:statistics, &filter_player_name(&1, old_term, term))
      |> assign(:term, term)

    {:noreply, new_socket}
  end

  defp filter_player_name(data, old_term, term) do
    data
    |> get_statistics_to_filter(old_term, term)
    |> Enum.filter(fn %{"Player" => name} -> String.contains?(name, term) end)
  end

  defp get_statistics_to_filter(current_statistics, old_term, term) do
    if String.length(term) > String.length(old_term) do
      current_statistics
    else
      Statistics.get_nfl_rushing_statistics()
    end
  end
end
