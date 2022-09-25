import Foundation


public protocol HTTPCall<ResponseBody> {
  associatedtype ResponseBody
  func call(configuration: HTTPCallConfiguration) async throws -> (ResponseBody, HTTPURLResponse)
}


public extension HTTPCall {
  func execute() async throws -> (ResponseBody, HTTPURLResponse) {
    try await call(configuration: HTTPCallConfiguration())
  }

  func execute() async throws -> ResponseBody {
    try await call(configuration: HTTPCallConfiguration()).0
  }
}
