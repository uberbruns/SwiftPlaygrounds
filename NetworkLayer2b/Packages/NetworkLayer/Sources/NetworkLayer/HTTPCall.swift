import Foundation


public protocol HTTPCall {
  associatedtype ResponseBody
  func call(configuration: HTTPCallConfiguration) async throws -> (ResponseBody, URLResponse)
}


public extension HTTPCall {
  func execute() async throws -> (ResponseBody, URLResponse) {
    try await call(configuration: HTTPCallConfiguration())
  }

  func execute() async throws -> ResponseBody {
    try await call(configuration: HTTPCallConfiguration()).0
  }
}
