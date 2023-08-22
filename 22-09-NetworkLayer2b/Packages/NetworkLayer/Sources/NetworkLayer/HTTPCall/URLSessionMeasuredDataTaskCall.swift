import Foundation


@available(iOS 15.0, *)
@available(macOS 12.0, *)
public class URLSessionMeasuredDataTaskCall: NSObject, HTTPCall {
  let urlSession: URLSession

  public init(urlSession: URLSession = URLSession.shared) {
    self.urlSession = urlSession
  }

  public func call(configuration: HTTPCallConfiguration) async throws -> (Data, HTTPURLResponse) {
    let (data, urlResponse) = try await urlSession.data(for: configuration.finalize(), delegate: self)
    guard let urlResponse = urlResponse as? HTTPURLResponse else { throw HTTPCallError.URLSessionMeasuredDataTask.invalidResponse }
    return (data, urlResponse)
  }
}


@available(iOS 15.0, *)
@available(macOS 12.0, *)
extension URLSessionMeasuredDataTaskCall: URLSessionTaskDelegate {
  public func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
    print(metrics.taskInterval.duration)
  }
}


public extension HTTPCallError {
  enum URLSessionMeasuredDataTask: Error {
    case invalidResponse
  }
}
