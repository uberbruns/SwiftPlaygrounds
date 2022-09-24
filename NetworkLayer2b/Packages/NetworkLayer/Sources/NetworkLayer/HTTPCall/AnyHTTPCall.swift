import Foundation


public struct AnyHTTPCall<ResponseBody>: HTTPCall {
  let callFunc: (HTTPCallConfiguration) async throws -> (ResponseBody, URLResponse)

  public init<Call: HTTPCall>(_ httpCall: Call) where Call.ResponseBody == ResponseBody {
    callFunc = httpCall.call
  }

  public func call(configuration: HTTPCallConfiguration) async throws -> (ResponseBody, URLResponse) {
    try await callFunc(configuration)
  }
}


public extension HTTPCall {
  func eraseToAnyHTTPCall() -> AnyHTTPCall<ResponseBody> {
    AnyHTTPCall(self)
  }
}
