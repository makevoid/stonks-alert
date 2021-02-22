require_relative 'lib/env'

class App < Roda
  plugin :render, engine: :haml
  plugin :public

  ROUTES = -> (r) {
    r.root {
      STATE = {}
      STATE[:stonks] ||= STONKS
      view "index"
    }

    r.get("page2") {
      view "page2"
    }

    r.public # if ENV["RACK_ENV"] == "development"
  }

  route &ROUTES
end
