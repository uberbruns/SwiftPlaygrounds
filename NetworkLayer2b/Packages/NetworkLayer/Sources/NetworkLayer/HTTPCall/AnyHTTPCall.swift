import Foundation


public struct AnyHTTPCall<ResponseBody>: HTTPCall {
  let callFunc: (URLRequest) async throws -> (ResponseBody, URLResponse)

  public init<Call: HTTPCall>(_ httpCall: Call) where Call.ResponseBody == ResponseBody {
    callFunc = httpCall.call
  }

  public func call(request: URLRequest) async throws -> (ResponseBody, URLResponse) {
    try await callFunc(request)
  }
}


public extension HTTPCall {
  func eraseToAnyHTTPCall() -> AnyHTTPCall<ResponseBody> {
    AnyHTTPCall(self)
  }
}
