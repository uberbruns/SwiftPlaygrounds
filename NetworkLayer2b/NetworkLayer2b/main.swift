import Foundation
import NetworkLayer


struct Person: Codable {
  let name: String
}

struct StarWarsAPI {
  private let root = URLSessionDataTaskCall()
      .url("https://swapi.dev")
      .appendPathComponent("api")
      .eraseToAnyHTTPCall()

  func people(id: Int) async throws -> Person {
    try await root
      .method(.get)
      .appendPathComponent("people/\(id)")
      .requestModifier { request in
        request.networkServiceType = .responsiveData
      }
      .decodeJSONResponse(Person.self)
      .execute()
  }
}


let api = StarWarsAPI()

let person = try await api.people(id: 1)
print(person.name)
