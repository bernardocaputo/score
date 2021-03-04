FROM elixir:1.11

RUN apt-get -y update && apt-get -y  upgrade && apt-get -y install inotify-tools

RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix archive.install --force hex phx_new 1.5.8 

WORKDIR /app

COPY mix.exs .

RUN mix deps.get && mix deps.compile 

COPY ./assets/package.json ./assets/package.json

RUN apt-get -yq install curl gnupg ca-certificates \
    && curl -L https://deb.nodesource.com/setup_14.x | bash \
    && apt-get install -yq \
    nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN cd ./assets && npm install && npm rebuild node-sass

COPY . .

RUN mix compile

EXPOSE 4000

CMD ["mix", "phx.server"]