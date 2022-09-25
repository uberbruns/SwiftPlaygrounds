import Foundation


public struct JSONResponseBodyModifier<T: Decodable>: HTTPCallModifier {

  init<T>(_ type: T.Type) { }

  public func call(configuration: HTTPCallConfiguration, execute: (HTTPCallConfiguration) async throws -> (Data, URLResponse)) async throws -> (T, URLResponse) {
    let (data, response) = try await execute(configuration)
    let decoded = try JSONDecoder().decode(T.self, from: data)
    return (decoded, response)
  }
}


public extension HTTPCall where ResponseBody == Data {
  func jsonResponseBody<T: Decodable>(_ type: T.Type) -> some HTTPCall<T> {
    modifier(JSONResponseBodyModifier<T>(type))
  }
}
