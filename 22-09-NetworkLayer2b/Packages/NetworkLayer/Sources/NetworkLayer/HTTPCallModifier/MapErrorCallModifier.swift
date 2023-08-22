import Foundation


public struct MapErrorCallModifier<ResponseBody, E: Error>: HTTPCallModifier {
  let transform: (ResponseBody, HTTPURLResponse) async throws -> E

  public func call(
    configuration: HTTPCallConfiguration,
    execute: (HTTPCallConfiguration
  ) async throws-> (ResponseBody, HTTPURLResponse)) async throws -> (Result<ResponseBody, E>, HTTPURLResponse) {
    let (body, response) = try await execute(configuration)
    if response.statusCode >= 400 {
      let transformedBody = try await transform(body, response)
      return (.failure(transformedBody), response)
    } else {
      return (.success(body), response)
    }
  }
}


public struct ThrowOnErrorCodeCallModifier<ResponseBody, E: Error>: HTTPCallModifier {
  let transform: (ResponseBody, HTTPURLResponse) async throws -> E

  public func call(
    configuration: HTTPCallConfiguration,
    execute: (HTTPCallConfiguration
  ) async throws-> (ResponseBody, HTTPURLResponse)) async throws -> (ResponseBody, HTTPURLResponse) {
    let (body, response) = try await execute(configuration)
    if response.statusCode >= 400 {
      let error = try await transform(body, response)
      throw error
    } else {
      return (body, response)
    }
  }
}


public extension HTTPCall {
  func throwOnErrorCode<E: Error>(_ transform: @escaping (ResponseBody, HTTPURLResponse) async throws -> E) -> some HTTPCall<ResponseBody> {
    modifier(ThrowOnErrorCodeCallModifier(transform: transform))
  }
}
