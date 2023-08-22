import Foundation


public struct MapCallModifier<ResponseBody, T>: HTTPCallModifier {
  let transform: (ResponseBody) async throws -> T

  public func call(configuration: HTTPCallConfiguration, execute: (HTTPCallConfiguration) async throws -> (ResponseBody, HTTPURLResponse)) async throws -> (T, HTTPURLResponse) {
    let (body, response) = try await execute(configuration)
    let transformedBody = try await transform(body)
    return (transformedBody, response)
  }
}

public extension HTTPCall {
  func map<T>(_ transform: @escaping (ResponseBody) async throws -> T) -> some HTTPCall<T> {
    modifier(MapCallModifier(transform: transform))
  }
}
