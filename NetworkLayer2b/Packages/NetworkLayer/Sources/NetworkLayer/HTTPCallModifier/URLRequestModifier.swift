import Foundation


public struct URLRequestModifier<ResponseBody>: HTTPCallModifier  {
  let mutate: (inout URLRequest) -> Void

  public init(_ mutate: @escaping (inout URLRequest) -> Void) {
    self.mutate = mutate
  }

  public func call(request: URLRequest, execute: (URLRequest) async throws -> (ResponseBody, URLResponse)) async throws -> (ResponseBody, URLResponse) {
    var request = request
    mutate(&request)
    return try await execute(request)
  }
}


public extension HTTPCall {
  func requestModifier(request mutate: @escaping (inout URLRequest) -> Void) -> ModifiedHTTPCall<Self, URLRequestModifier<Self.ResponseBody>> {
    modifier(URLRequestModifier(mutate))
  }

  func url(_ string: String) -> ModifiedHTTPCall<Self, URLRequestModifier<Self.ResponseBody>> {
    requestModifier { request in
      request.url = URL(string: string)!
    }
  }

  func url(_ url: URL) -> ModifiedHTTPCall<Self, URLRequestModifier<Self.ResponseBody>> {
    requestModifier { request in
      request.url = url
    }
  }

  func path(_ path: String) -> ModifiedHTTPCall<Self, URLRequestModifier<Self.ResponseBody>> {
    requestModifier { request in
      request.urlComponents?.path = path
    }
  }

  func method(_ method: StandardHTTPMethod) -> ModifiedHTTPCall<Self, URLRequestModifier<Self.ResponseBody>> {
    requestModifier { request in
      request.standardHTTPMethod = method
    }
  }

  func appendPathComponent(_ pathComponent: String) -> ModifiedHTTPCall<Self, URLRequestModifier<Self.ResponseBody>> {
    requestModifier { request in
      request.url?.appendPathComponent(pathComponent)
    }
  }

  func addQueryItem(name: String, value: String?) -> ModifiedHTTPCall<Self, URLRequestModifier<Self.ResponseBody>> {
    requestModifier { request in
      var newQueryItems = request.urlComponents?.queryItems ?? []
      newQueryItems.append(URLQueryItem(name: name, value: value))
      request.urlComponents?.queryItems = newQueryItems
    }
  }

  func requestBody(_ data: Data?) -> ModifiedHTTPCall<Self, URLRequestModifier<Self.ResponseBody>> {
    requestModifier { request in
      request.httpBody = data
    }
  }
}
