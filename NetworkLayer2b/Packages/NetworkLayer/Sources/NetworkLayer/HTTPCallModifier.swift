import Foundation


public protocol HTTPCallModifier<ResponseBodyIn, ResponseBodyOut> {
  associatedtype ResponseBodyIn
  associatedtype ResponseBodyOut
  func call(configuration: HTTPCallConfiguration, execute: (HTTPCallConfiguration) async throws -> (ResponseBodyIn, HTTPURLResponse)) async throws -> (ResponseBodyOut, HTTPURLResponse)
}
