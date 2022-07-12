import gleam/bit_builder.{BitBuilder}
import gleam/dynamic.{field, string}
import gleam/erlang
import gleam/erlang/os
import gleam/int
import gleam/list
import gleam/io
import gleam/string
import gleam/result
import gleam/http
import gleam/http/request.{Request}
import gleam/http/response.{Response}
import gleam/json.{DecodeError, object, preprocessed_array}
import mist
import mist/http as mhttp

type Order {
  Order(discord_id: String, email: String)
}

pub fn main() {
  let port =
    os.get_env("PORT")
    |> result.then(int.parse)
    |> result.unwrap(3000)

  ["Listening on http://localhost:", int.to_string(port), " ✨"]
  |> string.concat()
  |> io.print()

  assert Ok(_) = mist.serve(port, mhttp.handler(router))
  erlang.sleep_forever()
}

fn router(req: Request(BitString)) -> Response(BitBuilder) {
  case req.method, request.path_segments(req) {
    http.Post, ["order"] ->
      case parse_json(req.body) {
        Ok(order) ->
          response.new(200)
          |> response.set_body(bit_builder.from_string(order.discord_id))
        Error(_) ->
          response.new(500)
          |> response.set_body(bit_builder.from_string("yo wtf"))
      }
    http.Get, ["order", "list"] -> {
      let orders = [
        Order("12345", "rte@asd.com"),
        Order("67890", "asdf@asd.com"),
      ]
      let json = gen_json(orders)
      response.new(200)
      |> response.set_body(bit_builder.from_string(json))
    }
    _, _ ->
      response.new(404)
      |> response.set_body(bit_builder.from_string("not found"))
  }
}

fn parse_json(json_string: BitString) -> Result(Order, DecodeError) {
  let decoder =
    dynamic.decode2(
      Order,
      field("discord_id", of: string),
      field("email", of: string),
    )

  json.decode_bits(from: json_string, using: decoder)
}

fn gen_json(orders: List(Order)) -> String {
  orders
  |> list.map(fn(order) {
    object([
      #("discord_id", json.string(order.discord_id)),
      #("email", json.string(order.email)),
    ])
  })
  |> preprocessed_array()
  |> json.to_string()
}
