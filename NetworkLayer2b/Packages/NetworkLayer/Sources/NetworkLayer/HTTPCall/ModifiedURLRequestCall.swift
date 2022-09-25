import Foundation


public struct ModifiedURLRequestCall<Call: HTTPCall>: HTTPCall {
  let mutate: (inout URLRequest) -> Void

  let original: Call

  public init(original: Call, mutate: @escaping (inout URLRequest) -> Void) {
    self.original = original
    self.mutate = mutate
  }

  public func call(configuration: HTTPCallConfiguration) async throws -> (Call.ResponseBody, URLResponse) {
    try await original.call(
      configuration: configuration.addingRequestMutation(mutate)
    )
  }
}


public extension HTTPCall {
  func requestModifier(_ mutate: @escaping (inout URLRequest) -> Void) -> ModifiedURLRequestCall<Self> {
    ModifiedURLRequestCall(original: self, mutate: mutate)
  }

  func url(_ string: String) -> ModifiedURLRequestCall<Self> {
    requestModifier { request in
      request.url = URL(string: string)!
    }
  }

  func url(_ url: URL) -> ModifiedURLRequestCall<Self> {
    requestModifier { request in
      request.url = url
    }
  }

  func path(_ path: String) -> ModifiedURLRequestCall<Self> {
    requestModifier { request in
      request.urlComponents?.path = path
    }
  }

  func method(_ method: StandardHTTPMethod) -> ModifiedURLRequestCall<Self> {
    requestModifier { request in
      request.standardHTTPMethod = method
    }
  }

  func appendPathComponent(_ pathComponent: String) -> ModifiedURLRequestCall<Self> {
    requestModifier { request in
      request.url?.appendPathComponent(pathComponent)
    }
  }

  func addQueryItem(name: String, value: String?) -> ModifiedURLRequestCall<Self> {
    requestModifier { request in
      var newQueryItems = request.urlComponents?.queryItems ?? []
      newQueryItems.append(URLQueryItem(name: name, value: value))
      request.urlComponents?.queryItems = newQueryItems
    }
  }

  func requestBody(_ data: Data?) -> ModifiedURLRequestCall<Self> {
    requestModifier { request in
      request.httpBody = data
    }
  }

}
