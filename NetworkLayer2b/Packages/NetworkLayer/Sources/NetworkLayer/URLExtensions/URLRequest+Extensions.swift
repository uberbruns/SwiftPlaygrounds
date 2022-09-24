import Foundation


public extension URLRequest {
  var urlComponents: URLComponents? {
    get {
      guard let url = url else { return nil }
      return URLComponents(url: url, resolvingAgainstBaseURL: true)
    }
    set {
      url = newValue?.url
    }
  }


  var standardHTTPMethod: StandardHTTPMethod? {
    get {
      httpMethod.map(StandardHTTPMethod.init(rawValue:))
    }
    set {
      httpMethod = newValue?.rawValue
    }
  }
}


public enum StandardHTTPMethod {
  case get
  case put
  case head
  case post
  case patch
  case delete
  case other(String)

  var rawValue: String {
    switch self {
    case .get:
      return "GET"
    case .put:
      return "PUT"
    case .head:
      return "HEAD"
    case .post:
      return "POST"
    case .patch:
      return "PATCH"
    case .delete:
      return "DELETE"
    case .other(let value):
      return value
    }
  }

  init(rawValue: String) {
    switch rawValue {
    case "GET":
      self = .get
    case "PUT":
      self = .put
    case "HEAD":
      self = .head
    case "POST":
      self = .post
    case "PATCH":
      self = .patch
    case "DELETE":
      self = .delete
    default:
      self = .other(rawValue)
    }
  }
}
