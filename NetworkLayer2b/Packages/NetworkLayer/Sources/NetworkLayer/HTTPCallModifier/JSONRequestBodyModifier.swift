import Foundation


public struct JSONRequestBodyModifier<T: Encodable, ResponseBody>: HTTPCallModifier {

  private let body: T

  init(_ body: T) {
    self.body = body
  }

  public func call(configuration: HTTPCallConfiguration, execute: (HTTPCallConfiguration) async throws -> (ResponseBody, URLResponse)) async throws -> (ResponseBody, URLResponse) {
    try await execute(
      configuration.addingRequestMutation { request in
        request.httpBody = try JSONEncoder().encode(body)
      }
    )
  }
}


public extension HTTPCall {
  func jsonRequestBody<T: Encodable>(_ value: T) -> some HTTPCall<ResponseBody> {
    modifier(JSONRequestBodyModifier<T, ResponseBody>(value))
  }
}
