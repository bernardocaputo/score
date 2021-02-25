defmodule ScoreWeb.StatisticLive do
  use ScoreWeb, :live_view
  alias Score.Statistics

  def mount(_params, _session, socket) do
    new_socket = assign(socket, :statistics, Statistics.get_nfl_rushing_statistics())
    {:ok, new_socket}
  end

  def render(assigns) do
    ~L"""
    <h1> NFL Players Statistics </h1>
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
end
