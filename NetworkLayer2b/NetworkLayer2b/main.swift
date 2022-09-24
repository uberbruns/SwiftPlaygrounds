import Foundation
import NetworkLayer


struct Person: Codable {
  let name: String
}

struct StarWarsAPI {
  var starWars: AnyHTTPCall<Data> {
    URLSessionDataTaskCall()
      .url("https://swapi.dev")
      .appendPathComponent("api")
      .method(.get)
      .eraseToAnyHTTPCall()
  }

  func people(id: Int) -> some HTTPCall {
    starWars
      .appendPathComponent("people/\(id)")
      .decodeJSON(Person.self)
  }
}


let api = StarWarsAPI()

let luke = try await api.people(id: 1).call()
dump(luke)
