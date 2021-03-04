## Score APP

This application contains a NFL Rushing Statistics Table where you can sort by Total Rushing Yards, Longest Rush and Total Rushing Touchdowns

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

## Learn more
  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
