import Foundation


extension URL {
  func isSubset(of otherURL: URL) -> Bool {
    guard let urlComponents = URLComponents(url: self.standardized, resolvingAgainstBaseURL: false) else {
      return false
    }

    guard let otherURLComponents = URLComponents(url: otherURL.standardized, resolvingAgainstBaseURL: false) else {
      return false
    }

    if let scheme = urlComponents.scheme, scheme != otherURLComponents.scheme {
      return false
    }

    if let host = urlComponents.host, host != otherURLComponents.host {
      return false
    }

    do {
      let path = urlComponents.path.components(separatedBy: "/")
      let otherPath = otherURLComponents.path.components(separatedBy: "/")
      if !otherPath.starts(with: path) {
        return false
      }
    }

    do {
      let parameters = Set(urlComponents.queryItems?.map(\.name) ?? [])
      let otherParameters = Set(otherURLComponents.queryItems?.map(\.name) ?? [])
      if !parameters.isSubset(of: otherParameters) {
        return false
      }
    }

    return true
  }
}
