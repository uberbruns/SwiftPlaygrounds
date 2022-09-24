import Foundation


public struct HTTPCallConfiguration {
  typealias RequestMutation = (URLRequest) -> URLRequest

  private var urlRequestMutations = [RequestMutation]()

  public func finalizedRequest() -> URLRequest {
    var request = URLRequest(url: URL(string: "/")!)
    for urlRequestMutation in urlRequestMutations.reversed() {
      request = urlRequestMutation(request)
    }
    return request
  }
}
