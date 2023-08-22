import Foundation


public struct AnyHTTPCall<ResponseBody>: HTTPCall {
  private let erasedCall: (HTTPCallConfiguration) async throws -> (ResponseBody, HTTPURLResponse)

  public init<Call: HTTPCall>(_ httpCall: Call) where Call.ResponseBody == ResponseBody {
    erasedCall = httpCall.call
  }

  public func call(configuration: HTTPCallConfiguration) async throws -> (ResponseBody, HTTPURLResponse) {
    try await erasedCall(configuration)
  }
}


public extension HTTPCall {
  func eraseToAnyHTTPCall() -> AnyHTTPCall<ResponseBody> {
    AnyHTTPCall(self)
  }
}
