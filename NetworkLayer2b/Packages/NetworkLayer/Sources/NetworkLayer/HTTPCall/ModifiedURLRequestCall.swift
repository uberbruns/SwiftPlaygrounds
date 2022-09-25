import Foundation


public struct ModifiedURLRequestCall<Call: HTTPCall>: HTTPCall {
  let updateRequest: (inout URLRequest) -> Void

  let original: Call

  public init(original: Call, updateRequest: @escaping (inout URLRequest) -> Void) {
    self.original = original
    self.updateRequest = updateRequest
  }

  public func call(configuration: HTTPCallConfiguration) async throws -> (Call.ResponseBody, URLResponse) {
    try await original.call(
      configuration: configuration.addingRequestMutation(updateRequest)
    )
  }
}


public extension HTTPCall {
  func requestModifier(_ mutate: @escaping (inout URLRequest) -> Void) -> some HTTPCall<Self.ResponseBody> {
    ModifiedURLRequestCall(original: self, updateRequest: mutate)
  }

  func url(_ string: String) -> some HTTPCall<Self.ResponseBody> {
    requestModifier { request in
      request.url = URL(string: string)!
    }
  }

  func url(_ url: URL) -> some HTTPCall<Self.ResponseBody> {
    requestModifier { request in
      request.url = url
    }
  }

  func path(_ path: String) -> some HTTPCall<Self.ResponseBody> {
    requestModifier { request in
      request.urlComponents?.path = path
    }
  }

  func method(_ method: StandardHTTPMethod) -> some HTTPCall<Self.ResponseBody> {
    requestModifier { request in
      request.standardHTTPMethod = method
    }
  }

  func appendPathComponent(_ pathComponent: String) -> some HTTPCall<Self.ResponseBody> {
    requestModifier { request in
      request.url?.appendPathComponent(pathComponent)
    }
  }

  func addQueryItem(name: String, value: String?) -> some HTTPCall<Self.ResponseBody> {
    requestModifier { request in
      var newQueryItems = request.urlComponents?.queryItems ?? []
      newQueryItems.append(URLQueryItem(name: name, value: value))
      request.urlComponents?.queryItems = newQueryItems
    }
  }

  func requestBody(_ data: Data?) -> some HTTPCall<Self.ResponseBody> {
    requestModifier { request in
      request.httpBody = data
    }
  }
}
