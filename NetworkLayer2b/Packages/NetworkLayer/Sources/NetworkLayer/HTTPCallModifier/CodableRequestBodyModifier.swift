import Combine
import Foundation


@available(macOS 10.15, *)
public struct CodableRequestBodyModifier<T: Encodable, E: TopLevelEncoder, ResponseBody>: HTTPCallModifier where E.Output == Data {

  private let body: T
  private let encoder: E

  init(_ body: T, encoder: E) {
    self.body = body
    self.encoder = encoder
  }

  public func call(configuration: HTTPCallConfiguration, execute: (HTTPCallConfiguration) async throws -> (ResponseBody, HTTPURLResponse)) async throws -> (ResponseBody, HTTPURLResponse) {
    try await execute(
      configuration.addingRequestMutation { request in
        request.httpBody = try encoder.encode(body)
      }
    )
  }
}


@available(macOS 10.15, *)
public extension HTTPCall {
  func requestBody<T: Encodable, E: TopLevelEncoder>(_ value: T, encoder: E) -> some HTTPCall<ResponseBody> where E.Output == Data {
    modifier(CodableRequestBodyModifier<T, E, ResponseBody>(value, encoder: encoder))
  }
}
