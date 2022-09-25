import Foundation
import NetworkLayer


struct Person: Codable {
  let name: String
}


struct StarWarsAPI {
  private let root = URLSessionDataTaskCall()
      .url("https://swapi.dev")
      .appendPathComponent("api")

  func people(id: Int) async throws -> Person {
    try await root
      .method(.get)
      .appendPathComponent("people/\(id)")
      .decodeJSONResponse(Person.self)
      .execute()
  }
}


let swapi = StarWarsAPI()
let person = try await swapi.people(id: 1)

print(person.name)
