import Foundation


public struct HTTPCallConfiguration {
  private var urlRequestMutations: [(URLRequest) -> URLRequest]

  public init() {
    self.urlRequestMutations = []
  }

  private init(urlRequestMutations: [(URLRequest) -> URLRequest] = [(URLRequest) -> URLRequest]()) {
    self.urlRequestMutations = urlRequestMutations
  }

  public func addingRequestMutation(_ requestMutation: @escaping (inout URLRequest) -> Void) -> HTTPCallConfiguration {
    var mutableURLRequestMutations = urlRequestMutations
    mutableURLRequestMutations.append({ request in
      var mutableRequest = request
      requestMutation(&mutableRequest)
      return mutableRequest
    })
    return HTTPCallConfiguration(urlRequestMutations: mutableURLRequestMutations)
  }

  public func finalizedRequest() -> URLRequest {
    var request = URLRequest(url: URL(string: "/")!)
    for urlRequestMutation in urlRequestMutations.reversed() {
      request = urlRequestMutation(request)
    }
    return request
  }
}
