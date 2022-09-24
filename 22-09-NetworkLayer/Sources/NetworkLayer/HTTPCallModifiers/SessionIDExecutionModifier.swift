import Foundation


struct SessionIDExecutionModifier: HTTPExecutionModifier {
  static let sessionID = UUID().uuidString

  func modify(request: URLRequest, context: HTTPCallContext, execute: (URLRequest) async throws -> (Data, HTTPURLResponse)) async throws -> (Data, HTTPURLResponse) {
    var request = request
    request.setValue(Self.sessionID, forHTTPHeaderField: "moia-app-session-id")
    return try await execute(request)
  }
}
