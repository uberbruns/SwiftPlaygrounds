import Foundation


public struct DecodeJSONResponseModifier<T: Decodable>: HTTPCallModifier {
  public typealias ResponseBodyIn = Data
  public typealias ResponseBodyOut = T

  init<T>(_ type: T.Type) { }

  public func call(configuration: HTTPCallConfiguration, execute: (HTTPCallConfiguration) async throws -> (Data, URLResponse)) async throws -> (T, URLResponse) {
    let (data, response) = try await execute(configuration)
    let decoded = try JSONDecoder().decode(T.self, from: data)
    return (decoded, response)
  }
}


public extension HTTPCall where ResponseBody == Data {
  func decodeJSONResponse<T: Codable>(_ type: T.Type) -> ModifiedHTTPCall<Self, DecodeJSONResponseModifier<T>> {
    modifier(DecodeJSONResponseModifier<T>(type))
  }
}
