## Score Phoenix LiveView APP

This application contains a NFL Rushing Statistics Table where you can sort by Total Rushing Yards, Longest Rush and Total Rushing Touchdowns

## Notes
  - For this project, I decided to use Phoenix Liveview. It is the lightest, easiest to maintain and most performant way without the need for any javascript framework/code (everything is done on the server-side).

  - Since the NFL-rushing is a JSON file I figured that they want me to treat data in runtime (values from the same columns were randomly string or integer). Therefore I removed database dependencies and worked without a database. I set the JSON file as an @external_resouce module attribute which makes it to be pre-compiled with the code. If by anytime this file changes it gets recompiled. By doing that, the return of this data is instant. Another way to have the return of this data instantly would be to have it in an ETS table.

  - If the data were in a database I would have made a function using Enum.reduce/3 to have the result paginated and sorted in one single query to the database:
```elixir 
# Example
def database_query(opts) do
#  opts = [{:sort_options, %{sort_by: :yds, sort_order: :asc}}, {:page_options, %{page; 1, per_page: 20}}]

  query = (s in Statistic)

  Enum.reduce(opts, query, fn 
    {:sort_options, %{sort_by: sort_by, sort_order: sort_order}}, query -> 
      query
      |> order_by([s], {^sort_order, ^sort_by})
    {:page_options, %{page: page, per_page: per_page}}, query ->
      offset = ...
      query
      |> limit([s], ˆper_page)
      |> offset([s], offset)
  end) 
end
```

## Technologies used:
  - Elixir
  - Phoenix LiveView

## System Requirements:
  - Docker

## Getting Started
  - Clone this project to your machine

```
git clone git@github.com:bernardocaputo/score.git
```

  - With docker initialized, build the image in your computer by running: 
```
cd score
docker build -t score 
```

  - Finally run the container by typing:
```
docker run --rm -it -p 4000:4000 score
```

  - Now the application will be running at:
## [http://localhost:4000/statistics](http://localhost:4000/statistics)

## Features (requested)
    - Filter list by player name
    - Infinite Scroll
    - Download CSV ordenated by current sort order and filter
    - Sort by Total Rushing Yards, Longest Rush or Total Rushing Touchdowns
    
## Extra Features (study purpose only)
    - Time
    - Dropdown with player name's suggestion

## Tests
  - To run tests, run the following command:

```
mix test
```

## Learn more
  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
