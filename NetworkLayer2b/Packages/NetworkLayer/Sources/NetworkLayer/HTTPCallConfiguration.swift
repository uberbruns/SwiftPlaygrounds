import Foundation


public struct HTTPCallConfiguration {
  private var urlRequestMutations = [(URLRequest) -> URLRequest]()

  public mutating func add(requestMutation: @escaping (inout URLRequest) -> Void) {
    urlRequestMutations.append({ request in
      var mutableRequest = request
      requestMutation(&mutableRequest)
      return mutableRequest
    })
  }

  public func finalizedRequest() -> URLRequest {
    var request = URLRequest(url: URL(string: "/")!)
    for urlRequestMutation in urlRequestMutations.reversed() {
      request = urlRequestMutation(request)
    }
    return request
  }
}
