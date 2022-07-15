FROM ghcr.io/gleam-lang/gleam:v0.22.1-erlang-alpine

WORKDIR /app/
COPY . ./

RUN gleam build

CMD ["gleam", "run"]