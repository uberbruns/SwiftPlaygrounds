import Foundation


@available(macOS 12.0, *)
open class HTTPBackendService: NSObject {

  var urlSession: URLSession {
    URLSession(configuration: .default, delegate: self, delegateQueue: nil)
  }

  func execute<RequestBody, ResponseBody, CallModifier: HTTPCallModifier>(
    call: HTTPCall<RequestBody, ResponseBody>,
    modifier: CallModifier
  ) async throws -> (ResponseBody, HTTPURLResponse) {
    let session = urlSession
    let context = HTTPCallContext(urlSession: session)

    let (data, response) = try await modifier.modify(request: call.request, context: context) { modifiedRequest in
      try await call.executor(session, modifiedRequest)
    }
    return (try call.decode(data), response)
  }

  func execute<RequestBody, ResponseBody>(call: HTTPCall<RequestBody, ResponseBody>) async throws -> (ResponseBody, HTTPURLResponse) {
    try await execute(call: call, modifier: NoOpHTTPCallModifier())
  }
}


@available(macOS 12.0, *)
extension HTTPBackendService: URLSessionTaskDelegate { }
