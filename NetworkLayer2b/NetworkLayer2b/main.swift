import Foundation
import NetworkLayer


struct Person: Codable {
  let name: String
}


struct StarWarsAPI {
  private var apiEntry: some HTTPCall<Data> {
    URLSessionMeasuredDataTaskCall()
      .url("https://swapi.dev")
      .appendPathComponent("api")
  }

  func people(id: Int) async throws -> Person {
    try await apiEntry
      .appendPathComponent("people/\(id)")
      .method(.get)
      .jsonResponseBody(Person.self)
      .execute()
  }
}


let swapi = StarWarsAPI()
let person = try await swapi.people(id: (0...50).randomElement()!)

print(person.name)
