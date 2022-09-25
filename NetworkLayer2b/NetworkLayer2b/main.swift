import Foundation
import NetworkLayer


struct Person: Codable {
  let name: String
}


struct StarWarsAPI {
  private var apiEntryPoint: some HTTPCall<Data> {
    URLSessionMeasuredDataTaskCall()
      .url("https://swapi.dev")
      .appendedPathComponent("api")
  }

  func people(id: Int) async throws -> Person {
    try await apiEntryPoint
      .appendedPathComponent("people/\(id)")
      .method(.get)
      .jsonResponseBody(Person.self)
      .execute()
  }
}


let swapi = StarWarsAPI()
let person = try await swapi.people(id: (0...50).randomElement()!)

print(person.name)
