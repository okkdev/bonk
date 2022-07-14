import gleam/erlang
import bonk/api
import bonk/database

pub fn main() {
  let db = database.connect()
  assert Ok(_) = database.run_migrations(db)

  api.start(db)

  erlang.sleep_forever()
}
