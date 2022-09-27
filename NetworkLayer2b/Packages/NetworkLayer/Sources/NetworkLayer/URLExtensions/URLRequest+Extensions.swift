import CryptoKit
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

  mutating func setBasicAuthorizationHeader(username: String, password: String) {
    let encodedCredentials = [username, password].joined(separator: ":").data(using: .utf8)!.base64EncodedString()
    let authorizationValue = ["Basic", encodedCredentials].joined(separator: " ")
    setValue(authorizationValue, forHTTPHeaderField: "Authorization")
  }

  @available(macOS 10.15, *)
  mutating func setDigestAuthorizationHeader(
    username: String,
    password: String,
    request: URLRequest,
    response: HTTPURLResponse
  ) -> Bool {
    let md5: (String) -> String = { input in
      Insecure.MD5.hash(data: input.data(using: .utf8)!).map { String(format: "%02hhx", $0) }.joined()
    }

    guard let wwwAuthHeaderValue = response.value(forHTTPHeaderField: "WWW-Authenticate") else {
      return false
    }

    let methodAndValues = wwwAuthHeaderValue.split(separator: " ", maxSplits: 1)
    let authScheme = String(methodAndValues[0])
    let credentials = String(methodAndValues[1])

    guard authScheme == "Digest" else {
      return false
    }

    var credentialValues = [String: String]()
    let credentialComponents = credentials.components(separatedBy: ",").map({ $0.trimmingCharacters(in: .whitespaces) })

    for credentialComponent in credentialComponents {
      let keyValuePair = credentialComponent.split(separator: "=", maxSplits: 1)
      guard keyValuePair.count == 2 else { continue }
      let key = keyValuePair[0]
      let value = keyValuePair[1].trimmingCharacters(in: CharacterSet(charactersIn: "\""))
      credentialValues[String(key)] = value
    }

    guard let realm = credentialValues["realm"],
          let nonce = credentialValues["nonce"],
          let qop = credentialValues["qop"],
          let digestURI = request.url?.path,
          let httpMethod = request.httpMethod else {
      return false
    }

    let cnonce = md5(UUID().uuidString)
    let nc = "000000001"
    let ha1 = md5([username, realm, password].joined(separator: ":"))
    let ha2 = md5([httpMethod, digestURI].joined(separator: ":"))
    let response = md5([ha1, nonce, nc, cnonce, qop, ha2].joined(separator: ":"))

    let headerValue = [
      "username=\"\(username)\"",
      "realm=\"\(realm)\"",
      "nonce=\"\(nonce)\"",
      "uri=\"\(digestURI)\"",
      "response=\"\(response)\"",
      "cnonce=\"\(cnonce)\"",
      "nc=\(nc)",
      "qop=\(qop)",
    ].joined(separator: ", ")

    setValue("Digest \(headerValue)", forHTTPHeaderField: "Authorization")

    return true
  }

  mutating func removeBasicAuthorizationHeader() {
    allHTTPHeaderFields?.removeValue(forKey: "Authorization")
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
