import Foundation


public protocol HTTPCallModifier {
  associatedtype ResponseBodyIn
  associatedtype ResponseBodyOut
  func call(request: URLRequest, execute: (URLRequest) async throws -> (ResponseBodyIn, URLResponse)) async throws -> (ResponseBodyOut, URLResponse)
}
