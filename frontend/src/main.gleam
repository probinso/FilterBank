import gleam/dynamic/decode
import gleam/http/request
import gleam/int
import gleam/json
import lustre
import lustre/attribute
import lustre/component
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import lustre/server_component
import rsvp

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Nil
}

type Model {
  Model(count: Int, loading: Bool)
}

fn init(_) {
  #(Model(count: 0, loading: False), effect.none())
}

type Msg {
  CountInc
  CountDec
  CountResponse(Result(Int, rsvp.Error(String)))
}

fn update(model: Model, msg: Msg) {
  case msg {
    CountInc -> #(
      Model(..model, loading: True),
      send_count(model.count, "/api/counter/inc"),
    )
    CountDec -> #(
      Model(..model, loading: True),
      send_count(model.count, "/api/counter/dec"),
    )
    CountResponse(Ok(count)) -> #(
      Model(count: count, loading: False),
      effect.none(),
    )
    CountResponse(Error(_)) -> #(Model(..model, loading: False), effect.none())
  }
}

fn view(model: Model) -> Element(Msg) {
  let status = case model.loading {
    True -> "Loading"
    False -> "Ready"
  }
  html.div([], [
    html.p([], [html.text(status)]),
    html.button([event.on_click(CountDec), attribute.disabled(model.loading)], [
      html.text("-"),
    ]),
    html.p([], [html.text("Count: "), html.text(int.to_string(model.count))]),
    html.button([event.on_click(CountInc), attribute.disabled(model.loading)], [
      html.text("+"),
    ]),
  ])
}

fn send_count(count: Int, path: String) -> Effect(Msg) {
  let body = json.object([#("count", json.int(count))])
  let decoder = {
    use count <- decode.field("count", decode.int)
    decode.success(count)
  }
  rsvp.post(path, body, rsvp.expect_json(decoder, CountResponse))
}
