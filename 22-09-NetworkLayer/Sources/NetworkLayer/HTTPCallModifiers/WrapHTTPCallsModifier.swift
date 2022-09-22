import Foundation


struct WrappingHTTPCallModifier<O: HTTPCallModifier, I: HTTPCallModifier>: HTTPCallModifier {
  let outer: O
  let inner: I

  func modify(request: URLRequest, context: HTTPCallContext, execute: (URLRequest) async throws -> (Data, HTTPURLResponse)) async throws -> (Data, HTTPURLResponse) {
    try await outer.modify(request: request, context: context) { newRequest in
      try await inner.modify(request: newRequest, context: context, execute: execute)
    }
  }
}


extension HTTPCallModifier {
  func add<I: HTTPCallModifier>(_ innerModifier: I) -> WrappingHTTPCallModifier<Self, I> {
    WrappingHTTPCallModifier(outer: self, inner: innerModifier)
  }
}
