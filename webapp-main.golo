module main

import kiss
import kiss.request
import kiss.response
import kiss.httpExchange

import Distributed

import gololang.concurrent.workers.WorkerEnvironment

local function push_incoming_message = |resp, message| {
  resp: SSEWrite(message)
}

function main = |args| {

  let lightning_queue = queue("lightning")
  let all_messages = distributed_list("messages")
  let workers = WorkerEnvironment.builder(): withFixedThreadPool()

  let server = HttpServer("0.0.0.0", 8080, |app| {

    app: static("/public", "index.html")

    app: $get("/all-messages", |resp, req| -> resp: json(DynamicObject(): messages(all_messages)))

    app: $get("/messages", |resp, req| {
      resp: SSEInit()
      let port = workers: spawn(^push_incoming_message: bindTo(resp))
      all_messages: addItemListener(item_listener(
        |this, event| -> port: send(event: getItem()),
        |this, event| { }), true)
    })

    app: $get("/lightning", |resp, req| {
      resp: SSEInit()
      Thread({
        let COLORS = ["#666", "#777", "#888", "#999", "#aaa", "#bbb", "#ccc", "#ddd", "#eee", "#fff"]
        var COLOR = COLORS: size() - 1
        resp: SSEWrite(COLORS: get(COLOR))
        while true {
          let action = lightning_queue: take()
          if action == "up" {
            if COLOR < (COLORS: size() - 1) {
              COLOR = COLOR + 1
            }
          } else {
            if COLOR > 0 {
              COLOR = COLOR - 1
            }
          }
          resp: SSEWrite(COLORS: get(COLOR))
        }
      }): start()
    })

  })

  server: watch(["/", "/public", "/public/js"], |events| {
    events: each(|event| -> println(event: kind() + " " + event: context()))
    java.lang.System.exit(1)
  })

  server: start(">>> Running on http://localhost:8080/")
}
