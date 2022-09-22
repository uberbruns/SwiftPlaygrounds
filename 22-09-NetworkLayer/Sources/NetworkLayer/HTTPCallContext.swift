import Foundation


final class HTTPCallContext {
  let urlSession: URLSession

  init(urlSession: URLSession) {
    self.urlSession = urlSession
  }
}
