import Foundation


public struct AnyHTTPCall<ResponseBody>: HTTPCall {
  private let wrappedCall: (HTTPCallConfiguration) async throws -> (ResponseBody, URLResponse)

  public init<Call: HTTPCall>(_ httpCall: Call) where Call.ResponseBody == ResponseBody {
    wrappedCall = httpCall.call
  }

  public func call(configuration: HTTPCallConfiguration) async throws -> (ResponseBody, URLResponse) {
    try await wrappedCall(configuration)
  }
}


public extension HTTPCall {
  func eraseToAnyHTTPCall() -> AnyHTTPCall<ResponseBody> {
    AnyHTTPCall(self)
  }
}
