import Foundation


@available(macOS 12.0, *)
struct HTTPCall<RequestBody, DecodedResponse> {

  typealias Executor = (URLSession, URLRequest) async throws -> (Data, HTTPURLResponse)

  let request: URLRequest
  let decode: (Data) throws -> DecodedResponse
  let executor: Executor

  init(
    request: URLRequest,
    decode: @escaping (Data) throws -> DecodedResponse,
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
