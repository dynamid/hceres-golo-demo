module main

import kiss
import kiss.request
import kiss.response
import kiss.httpExchange

function main = |args| {

  let queue = Distributed.queue("lightning")

  let server = HttpServer("0.0.0.0", 8081, |app| {

    app: static("/public", "controller.html")

    app: $get("/up", |resp, req| {
      queue: put("up")
      resp: json(DynamicObject(): status("ok"))
      println(">>> lightning up")
    })

    app: $get("/down", |resp, req| {
      queue: put("down")
      resp: json(DynamicObject(): status("ok"))
      println(">>> lightning down")
    })

  })

  server: watch(["/", "/public", "/public/js"], |events| {
    events: each(|event| -> println(event: kind() + " " + event: context()))
    java.lang.System.exit(1)
  })

  server: start(">>> Running on http://localhost:8081/")
}
