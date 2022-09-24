import Foundation


@available(macOS 12.0, *)
public struct URLSessionDataTaskCall: HTTPCall {
  let urlSession: URLSession

  public init(urlSession: URLSession = URLSession.shared) {
    self.urlSession = urlSession
  }

  public func call(configuration: HTTPCallConfiguration) async throws -> (Data, URLResponse) {
    try await urlSession.data(for: configuration.finalizedRequest())
  }
}
