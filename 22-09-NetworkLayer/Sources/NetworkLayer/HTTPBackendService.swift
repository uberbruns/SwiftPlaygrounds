import Foundation


@available(macOS 12.0, *)
open class HTTPBackendService: NSObject {

  var urlSession: URLSession {
    URLSession(configuration: .default, delegate: self, delegateQueue: nil)
  }

  func execute<ResponseContent, ExecutionModifier: HTTPExecutionModifier>(
    call: HTTPCall<ResponseContent>,
    modifier: ExecutionModifier
  ) async throws -> (ResponseContent, HTTPURLResponse) {
    let session = urlSession
    let context = HTTPCallContext(urlSession: session)
    let (data, response) = try await modifier.modify(request: call.request, context: context) { modifiedRequest in
      try await call.executor(session, modifiedRequest)
    }
    return (try call.decode(data), response)
  }

  func execute<ResponseContent>(call: HTTPCall<ResponseContent>) async throws -> (ResponseContent, HTTPURLResponse) {
    try await execute(call: call, modifier: NoOpHTTPExecutionModifier())
  }
}


@available(macOS 12.0, *)
extension HTTPBackendService: URLSessionTaskDelegate { }
