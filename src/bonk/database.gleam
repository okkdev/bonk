import gleam/pgo
import gleam/result
import gleam/io
import gleam/option
import gleam/dynamic
import gleam/string
import gleam/erlang/os

pub fn connect() -> pgo.Connection {
  let config =
    os.get_env("DATABASE_URL")
    |> result.then(pgo.url_config)
    |> result.lazy_unwrap(fn() {
      pgo.Config(
        ..pgo.default_config(),
        host: "localhost",
        database: "bonk_dev",
        user: "postgres",
        password: option.Some("postgres"),
      )
    })

  pgo.connect(pgo.Config(..config, pool_size: 15))
}

pub fn run_migrations(db: pgo.Connection) -> Result(String, pgo.QueryError) {
  try _ =
    exec(
      db,
      "create_table_orders",
      "create table if not exists orders (
      id serial
        primary key,
      inserted_at timestamp
        default now(),
      discord_id varchar(255)
        unique
        not null,
      email varchar(255)
        not null
    )",
    )

  io.println("All Migrations completed")
  Ok("All Migrations completed")
}

fn exec(
  db: pgo.Connection,
  name: String,
  sql: String,
) -> Result(String, pgo.QueryError) {
  io.println(string.concat(["Running migration ", name]))
  try _ = pgo.execute(sql, on: db, with: [], expecting: dynamic.dynamic)

  Ok(string.concat(["Migration ", name, " completed"]))
}
