import Foundation


public protocol HTTPCall {
  associatedtype ResponseBody
  func call(request: URLRequest) async throws -> (ResponseBody, URLResponse)
}


public extension HTTPCall {
  func call() async throws -> (ResponseBody, URLResponse) {
    try await call(request: URLRequest(url: URL(string: "/")!))
  }
}
