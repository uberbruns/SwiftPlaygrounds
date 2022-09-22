import Foundation


protocol HTTPCallModifier {
  func modify(
    request: URLRequest,
    context: HTTPCallContext,
    execute: (URLRequest) async throws -> (Data, HTTPURLResponse)
  ) async throws -> (Data, HTTPURLResponse)
}
