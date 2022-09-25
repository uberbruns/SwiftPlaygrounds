import Foundation


@available(macOS 12.0, *)
public class URLSessionMeasuredDataTaskCall: NSObject, HTTPCall {
  let urlSession: URLSession

  public init(urlSession: URLSession = URLSession.shared) {
    self.urlSession = urlSession
  }

  public func call(configuration: HTTPCallConfiguration) async throws -> (Data, URLResponse) {
    try await withUnsafeThrowingContinuation { [self] continuation in
      let task = urlSession.dataTask(
        with: configuration.finalize(),
        completionHandler: { data, response, error in
          switch (data, response, error) {
          case let (data?, response?, _):
            continuation.resume(returning: (data, response))
          case let (_, _, error?):
            continuation.resume(throwing: error)
          default:
            fatalError()
          }
        }
      )
      task.delegate = self
      task.resume()
    }
  }
}


@available(macOS 12.0, *)
extension URLSessionMeasuredDataTaskCall: URLSessionTaskDelegate {
  public func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
    print(metrics.taskInterval.duration)
  }
}
