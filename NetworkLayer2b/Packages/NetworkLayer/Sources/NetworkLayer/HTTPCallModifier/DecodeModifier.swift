import Foundation


public struct DecodeJSONModifier<T: Decodable>: HTTPCallModifier {
  public typealias ResponseBodyIn = Data
  public typealias ResponseBodyOut = T

  init<T>(_ type: T.Type) { }

  public func call(request: URLRequest, execute: (URLRequest) async throws -> (Data, URLResponse)) async throws -> (T, URLResponse) {
    let (data, response) = try await execute(request)
    let decoded = try JSONDecoder().decode(T.self, from: data)
    return (decoded, response)
  }
}


public extension HTTPCall where ResponseBody == Data {
  func decodeJSON<T: Codable>(_ type: T.Type) -> some HTTPCall {
    modifier(DecodeJSONModifier<T>(type))
  }
}
