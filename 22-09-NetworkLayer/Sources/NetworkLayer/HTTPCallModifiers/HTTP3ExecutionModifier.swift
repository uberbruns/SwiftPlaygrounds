import Foundation


struct HTTP3ExecutionModifier: HTTPExecutionModifier {
  func modify(request: URLRequest, context: HTTPCallContext, execute: (URLRequest) async throws -> (Data, HTTPURLResponse)) async throws -> (Data, HTTPURLResponse) {
    var request = request
    if #available(macOS 11.3, *) {
      request.assumesHTTP3Capable = true
    }
    return try await execute(request)
  }
}
