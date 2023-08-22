import Combine
import Foundation


@available(macOS 10.15, *)
@available(iOS 13.0, *)
public actor CodableResponseBodyModifier<T: Decodable, D: TopLevelDecoder>: HTTPCallModifier where D.Input == Data {

  private let decoder: D

  init<T>(_ type: T.Type, decoder: D) {
    self.decoder = decoder
  }

  public func call(configuration: HTTPCallConfiguration, execute: (HTTPCallConfiguration) async throws -> (Data, HTTPURLResponse)) async throws -> (T, HTTPURLResponse) {
    let (data, response) = try await execute(configuration)
    let decoded = try decoder.decode(T.self, from: data)
    return (decoded, response)
  }
}


@available(macOS 10.15, *)
@available(iOS 13.0, *)
public extension HTTPCall where ResponseBody == Data {
  func responseBody<T: Decodable, D: TopLevelDecoder>(_ type: T.Type, decoder: D) -> some HTTPCall<T> where D.Input == Data {
    modifier(CodableResponseBodyModifier<T, D>(type, decoder: decoder))
  }
}
