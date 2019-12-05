FROM elixir:1.9.1-alpine as build

# create workdir
RUN mkdir /app
WORKDIR /app

# install basic libs
RUN apk add --update build-base

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV=prod

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get
RUN mix deps.compile

# build project
COPY priv priv
COPY lib lib
RUN mix compile

# build release
COPY rel rel
RUN mix release

# prepare release image
FROM alpine:3.9 AS app

RUN apk add --update bash openssl postgresql-client

RUN mkdir /app
WORKDIR /app

COPY --from=build /app/_build/prod/rel/stone_bank ./
RUN chown -R nobody: /app
USER nobody

COPY scripts scripts

ENV HOME=/app
ENV PATH=/app/bin:$PATH

CMD ["stone_bank", "start"]
