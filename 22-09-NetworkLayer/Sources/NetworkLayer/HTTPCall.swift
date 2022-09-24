import Foundation


@available(macOS 12.0, *)
struct HTTPCall<ResponseContent> {

  typealias Executor = (URLSession, URLRequest) async throws -> (Data, HTTPURLResponse)

  var request: URLRequest

  var decode: (Data) throws -> ResponseContent

  var executor: Executor

  init(
    request: URLRequest,
    decode: @escaping (Data) throws -> ResponseContent,
    executor: @escaping Executor = Self.dataExecutor
  ) {
    self.request = request
    self.decode = decode
    self.executor = executor
  }
}



@available(macOS 12.0, *)
private extension HTTPCall {
  static var dataExecutor: Executor {
    return { urlSession, urlRequest in
      let (data, urlResponse) = try await urlSession.data(for: urlRequest)
      return (data, urlResponse as! HTTPURLResponse)
    }
  }

  static func uploadExecutor(data: Data) -> Executor {
    return { urlSession, urlRequest in
      let (data, urlResponse) = try await urlSession.upload(for: urlRequest, from: data)
      return (data, urlResponse as! HTTPURLResponse)
    }
  }
}



@available(macOS 12.0, *)
extension HTTPCall where ResponseContent == Data {
  init(url: URL) {
    self = .init(
      request: URLRequest(url: url),
      decode: { $0 }
    )
  }

  func decodeResponse<M: Message>(as messageType: M.Type) -> HTTPCall<M> {
    .init(
      request: self.request,
      decode: { data in
        try messageType.init(data: data)
      }
    )
  }

}

@available(macOS 12.0, *)
extension HTTPCall {
  func path(_ path: String) -> Self {
    var newCall = self
    newCall.request.urlComponents?.path = path
    return newCall
  }

  func method(_ standardHTTPMethod: StandardHTTPMethod) -> Self {
    var newCall = self
    newCall.request.standardHTTPMethod = standardHTTPMethod
    return newCall
  }

  func appendPathComponent(_ pathComponent: String) -> Self {
    var newCall = self
    newCall.request.url?.appendPathComponent(pathComponent)
    return newCall
  }

  func addQueryItem(name: String, value: String?) -> Self {
    var newCall = self
    var newQueryItems = newCall.request.urlComponents?.queryItems ?? []
    newQueryItems.append(URLQueryItem(name: name, value: value))
    newCall.request.urlComponents?.queryItems = newQueryItems
    return newCall
  }

  func requestBody(from data: Data?) -> Self {
    var newCall = self
    newCall.request.httpBody = data
    return newCall
  }

}
