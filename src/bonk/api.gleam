import gleam/bit_builder.{BitBuilder}
import gleam/bit_string
import gleam/dynamic.{field, string}
import gleam/erlang/os
import gleam/int
import gleam/list
import gleam/pgo
import gleam/io
import gleam/string
import gleam/result
import gleam/http
import gleam/http/request.{Request}
import gleam/http/response.{Response}
import gleam/json.{DecodeError, object, preprocessed_array}
import mist
import mist/http as mhttp
import bonk/order.{Order}

pub type AppRequest {
  AppRequest(
    method: http.Method,
    path: List(String),
    headers: List(#(String, String)),
    body: String,
    db: pgo.Connection,
  )
}

pub fn start(db: pgo.Connection) {
  let port =
    os.get_env("PORT")
    |> result.then(int.parse)
    |> result.unwrap(3000)

  let web = fn(req) {
    req
    |> plug(db)
    |> router
  }

  assert Ok(_) = mist.serve(port, mhttp.handler(web))

  ["Listening on http://localhost:", int.to_string(port), " ✨"]
  |> string.concat()
  |> io.println()
}

fn plug(request: Request(BitString), db: pgo.Connection) -> AppRequest {
  AppRequest(
    method: request.method,
    path: request.path_segments(request),
    headers: request.headers,
    body: bit_string.to_string(request.body)
    |> result.unwrap(""),
    db: db,
  )
}

fn router(req: AppRequest) -> Response(BitBuilder) {
  io.println("Received request:")
  io.debug(req)

  case req.method, req.path {
    http.Post, ["order"] ->
      case parse_json(req.body) {
        Ok(order) ->
          case order.insert(req.db, order) {
            Ok(_) ->
              response.new(201)
              |> response.set_body(bit_builder.from_string(
                "Success inserting order",
              ))
            Error(_) ->
              response.new(500)
              |> response.set_body(bit_builder.from_string(
                "Error inserting order",
              ))
          }
        Error(_) ->
          response.new(500)
          |> response.set_body(bit_builder.from_string("yo wtf"))
      }
    http.Get, ["order", "list"] -> {
      let json =
        req.db
        |> order.get_all()
        |> gen_json()
      response.new(200)
      |> response.set_body(bit_builder.from_string(json))
    }
    _, _ ->
      response.new(404)
      |> response.set_body(bit_builder.from_string("not found"))
  }
}

fn parse_json(json_string: String) -> Result(Order, DecodeError) {
  let decoder =
    dynamic.decode2(
      Order,
      field("discord_id", of: string),
      field("email", of: string),
    )

  json.decode(from: json_string, using: decoder)
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
