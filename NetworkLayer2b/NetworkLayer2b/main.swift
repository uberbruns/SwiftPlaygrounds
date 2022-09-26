import Foundation
import NetworkLayer


struct Person: Codable {
  let name: String
}


struct StarWarsAPI {
  private let decoder = JSONDecoder()

  private var apiRoot: some HTTPCall<Data> {
    URLSessionMeasuredDataTaskCall()
      .url("https://swapi.dev")
      .appendedPathComponent("api")
  }

  func people(id: Int) async throws -> Person {
    try await apiRoot
      .appendedPathComponent("people/\(id)")
      .method(.get)
      .responseBody(Person.self, decoder: decoder)
      .execute()
  }
}


let swapi = StarWarsAPI()
let person = try await swapi.people(id: (0...50).randomElement()!)

print(person.name)
