import Foundation


public struct HTTPCallConfiguration {
  private var requestUpdates: [(URLRequest) throws -> URLRequest]

  public init() {
    self.requestUpdates = []
  }

  private init(requestUpdates: [(URLRequest) throws -> URLRequest] = [(URLRequest) throws -> URLRequest]()) {
    self.requestUpdates = requestUpdates
  }

  public func addingRequestMutation(_ requestUpdate: @escaping (inout URLRequest) throws -> Void) -> HTTPCallConfiguration {
    var mutableRequestUpdates = requestUpdates
    mutableRequestUpdates.append({ request in
      var mutableRequest = request
      try requestUpdate(&mutableRequest)
      return mutableRequest
    })
    return HTTPCallConfiguration(requestUpdates: mutableRequestUpdates)
  }

  public func finalize() throws -> URLRequest {
    guard let url = URL(string: "/") else { throw HTTPCallError.invalidRequest }
    var request = URLRequest(url: url)
    for requestUpdate in requestUpdates.reversed() {
      request = try requestUpdate(request)
    }
    return request
  }
}
