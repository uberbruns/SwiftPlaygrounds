import Foundation


@available(macOS 12.0, *)
@available(iOS 13.0, *)
public struct URLSessionDataTaskCall: HTTPCall {
  let urlSession: URLSession

  public init(urlSession: URLSession = URLSession.shared) {
    self.urlSession = urlSession
  }

  public func call(configuration: HTTPCallConfiguration) async throws -> (Data, HTTPURLResponse) {
    let (data, response) = try await urlSession.data(for: configuration.finalize())
    guard let response = response as? HTTPURLResponse else { throw HTTPCallError.unexpectedResponse }
    return (data, response)
  }
}
