FROM matteosister/elixir:1.2

RUN mix local.hex --force
RUN mix local.rebar --force
WORKDIR /code
COPY mix.* /code/
RUN mix do deps.get, deps.compile
