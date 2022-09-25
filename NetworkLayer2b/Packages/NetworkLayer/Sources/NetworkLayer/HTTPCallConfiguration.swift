import Foundation


public struct HTTPCallConfiguration {
  private var requestUpdates: [(URLRequest) -> URLRequest]

  public init() {
    self.requestUpdates = []
  }

  private init(requestUpdates: [(URLRequest) -> URLRequest] = [(URLRequest) -> URLRequest]()) {
    self.requestUpdates = requestUpdates
  }

  public func addingRequestMutation(_ requestUpdate: @escaping (inout URLRequest) -> Void) -> HTTPCallConfiguration {
    var mutableRequestUpdates = requestUpdates
    mutableRequestUpdates.append({ request in
      var mutableRequest = request
      requestUpdate(&mutableRequest)
      return mutableRequest
    })
    return HTTPCallConfiguration(requestUpdates: mutableRequestUpdates)
  }

  public func finalize() -> URLRequest {
    var request = URLRequest(url: URL(string: "/")!)
    for requestUpdate in requestUpdates.reversed() {
      request = requestUpdate(request)
    }
    return request
  }
}
