import Foundation


public struct ModifiedHTTPCall<Call: HTTPCall, Modifier: HTTPCallModifier>: HTTPCall where Call.ResponseBody == Modifier.ResponseBodyIn {
  let original: Call
  let modifier: Modifier

  public init(original: Call, modifier: Modifier) {
    self.original = original
    self.modifier = modifier
  }

  public func call(configuration: HTTPCallConfiguration) async throws -> (Modifier.ResponseBodyOut, HTTPURLResponse) {
    try await modifier.call(configuration: configuration, execute: original.call(configuration:))
  }
}


extension HTTPCall {
  func modifier<Modifier: HTTPCallModifier>(_ modifier: Modifier) -> ModifiedHTTPCall<Self, Modifier> {
    ModifiedHTTPCall(original: self, modifier: modifier)
  }
}
