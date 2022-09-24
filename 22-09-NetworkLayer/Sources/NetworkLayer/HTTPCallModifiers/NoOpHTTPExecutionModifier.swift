import Foundation


struct NoOpHTTPExecutionModifier: HTTPExecutionModifier {
  func modify(request: URLRequest, context: HTTPCallContext, execute: (URLRequest) async throws -> (Data, HTTPURLResponse)) async throws -> (Data, HTTPURLResponse) {
    try await execute(request)
  }
}
