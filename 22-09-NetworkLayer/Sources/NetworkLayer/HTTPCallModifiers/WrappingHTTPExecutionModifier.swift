import Foundation


struct WrappingHTTPExecutionModifier<O: HTTPExecutionModifier, I: HTTPExecutionModifier>: HTTPExecutionModifier {
  let outer: O
  let inner: I

  func modify(request: URLRequest, context: HTTPCallContext, execute: (URLRequest) async throws -> (Data, HTTPURLResponse)) async throws -> (Data, HTTPURLResponse) {
    try await outer.modify(request: request, context: context) { newRequest in
      try await inner.modify(request: newRequest, context: context, execute: execute)
    }
  }
}


extension HTTPExecutionModifier {
  func add<I: HTTPExecutionModifier>(_ innerModifier: I) -> WrappingHTTPExecutionModifier<Self, I> {
    WrappingHTTPExecutionModifier(outer: self, inner: innerModifier)
  }
}
