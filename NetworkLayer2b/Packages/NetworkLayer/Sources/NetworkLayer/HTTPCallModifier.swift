import Foundation


public protocol HTTPCallModifier {
  associatedtype ResponseBodyIn
  associatedtype ResponseBodyOut
  func call(configuration: HTTPCallConfiguration, execute: (HTTPCallConfiguration) async throws -> (ResponseBodyIn, URLResponse)) async throws -> (ResponseBodyOut, URLResponse)
}
