import Foundation
import NetworkLayer


struct GetResponse: Codable {
  let args: [String: String]
  let headers: [String: String]
  let url: String
}


struct PostRequest: Codable {
  let foo1: String
  let foo2: Int
}


struct PostResponse: Codable {
  let args: [String: String]
  let headers: [String: String]
  let url: String
  let json: PostRequest
}


struct BasicAuthResponse: Codable {
  let authenticated: Bool
}



struct EchoAPI {
  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()

  private var apiRoot: some HTTPCall<Data> {
    URLSessionMeasuredDataTaskCall()
      .url("https://postman-echo.com")
  }

  func testGET() async throws -> GetResponse {
    try await apiRoot
      .appendedPathComponent("get")
      .method(.get)
      .responseBody(GetResponse.self, decoder: decoder)
      .addedQueryItem(name: "foo1", value: "bar1")
      .addedQueryItem(name: "foo2", value: "bar2")
      .execute()
  }

  func testPOST() async throws -> PostResponse {
    try await apiRoot
      .appendedPathComponent("post")
      .contentType("application/json")
      .method(.post)
      .responseDump(enabled: false)
      .requestBody(PostRequest(foo1: "Caprica", foo2: 12), encoder: encoder)
      .responseBody(PostResponse.self, decoder: decoder)
      .addedQueryItem(name: "foo1", value: "bar1")
      .addedQueryItem(name: "foo2", value: "bar2")
      .execute()
  }

  func testBasicAuth() async throws -> BasicAuthResponse {
    try await apiRoot
      .appendedPathComponent("basic-auth")
      .basicAuthorization(username: "postman", password: "password")
      .method(.get)
      .responseBody(BasicAuthResponse.self, decoder: decoder)
      .execute()
  }

  func testDigestAuth() async throws -> Data {
    try await apiRoot
      .digestAuthorization(username: "postman", password: "password")
      .appendedPathComponent("digest-auth")
      .method(.get)
      .responseDump(enabled: true)
      .execute()
  }
}


do {
  let api = EchoAPI()
  let response = try await api.testDigestAuth()
  print(response)
} catch {
  dump(error)
}
