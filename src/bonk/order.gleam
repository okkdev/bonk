import gleam/pgo
import gleam/dynamic

pub type Order {
  Order(discord_id: String, email: String)
}

fn order_decoder() -> dynamic.Decoder(Order) {
  dynamic.decode2(
    Order,
    dynamic.element(0, dynamic.string),
    dynamic.element(1, dynamic.string),
  )
}

pub fn insert(db: pgo.Connection, order: Order) {
  let sql = "INSERT INTO orders (discord_id, email) VALUES ($1, $2)"

  pgo.execute(
    sql,
    on: db,
    with: [pgo.text(order.discord_id), pgo.text(order.email)],
    expecting: order_decoder(),
  )
}

pub fn get_all(db: pgo.Connection) -> List(Order) {
  let sql = "SELECT discord_id, email FROM orders"

  assert Ok(result) =
    pgo.execute(sql, on: db, with: [], expecting: order_decoder())

  result.rows
}
