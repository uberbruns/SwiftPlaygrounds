import Foundation


struct TraceIDExecutionModifier: HTTPExecutionModifier {
  func modify(request: URLRequest, context: HTTPCallContext, execute: (URLRequest) async throws -> (Data, HTTPURLResponse)) async throws -> (Data, HTTPURLResponse) {
    // Generate traceID
    let possibleCharacter = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    let randomString = String(possibleCharacter.shuffled()[0..<8])
    let traceID = "ipa_\(randomString)"

    // Add to request
    var request = request
    request.setValue(traceID, forHTTPHeaderField: "trace-id")
    return try await execute(request)
  }
}
