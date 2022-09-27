import Foundation


public struct ModifiedURLRequestCall<Call: HTTPCall>: HTTPCall {
  let updateRequest: (inout URLRequest) throws -> Void

  let original: Call

  public init(original: Call, updateRequest: @escaping (inout URLRequest) throws -> Void) {
    self.original = original
    self.updateRequest = updateRequest
  }

  public func call(configuration: HTTPCallConfiguration) async throws -> (Call.ResponseBody, HTTPURLResponse) {
    try await original.call(
      configuration: configuration.addingRequestMutation(updateRequest)
    )
  }
}


public extension HTTPCall {
  func requestModifier(_ updateRequest: @escaping (inout URLRequest) throws -> Void) -> some HTTPCall<Self.ResponseBody> {
    ModifiedURLRequestCall(original: self, updateRequest: updateRequest)
  }

  func url(_ string: String) -> some HTTPCall<Self.ResponseBody> {
    requestModifier { request in
      guard let url = URL(string: string) else { throw HTTPCallError.invalidRequest }
      request.url = url
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

  func method(_ method: String) -> some HTTPCall<Self.ResponseBody> {
    requestModifier { request in
      request.httpMethod = method
    }
  }

  func appendedPathComponent(_ pathComponent: String) -> some HTTPCall<Self.ResponseBody> {
    requestModifier { request in
      request.url?.appendPathComponent(pathComponent)
    }
  }

  func addedQueryItem(name: String, value: String?) -> some HTTPCall<Self.ResponseBody> {
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

  func httpHeaderField(_ field: String, value: String?) -> some HTTPCall<Self.ResponseBody> {
    requestModifier { request in
      request.setValue(value, forHTTPHeaderField: field)
    }
  }

  func basicAuthorization(username: String, password: String) -> some HTTPCall<Self.ResponseBody> {
    requestModifier { request in
      request.setBasicAuthorizationHeader(username: username, password: password)
    }
  }

  func contentType(_ contentType: String) -> some HTTPCall<Self.ResponseBody> {
    httpHeaderField("Content-Type", value: contentType)
  }
}
