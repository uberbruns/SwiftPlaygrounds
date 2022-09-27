import Foundation


public struct HTTPCallConfiguration {
  private var requestUpdates: [(URLRequest) throws -> URLRequest]

  public init() {
    self.requestUpdates = []
  }

  private init(requestUpdates: [(URLRequest) throws -> URLRequest] = [(URLRequest) throws -> URLRequest]()) {
    self.requestUpdates = requestUpdates
  }
}


/// A little explanation why this needed. Consider this example:
/// ```
/// 1 | URLSessionDataTaskCall()
/// 2 |   .url("https://example.com")
/// 3 |   .appendedPathComponent("api")
/// 4 |   .execute()
/// ```
/// A `HTTPCallModifier` wraps the original `HTTPCall`. This means the modifiers code that is written before
/// the execution of the supplied `execute` closure runs _before_ the code of the original `HTTPCall`.
/// This has the unfortunate side effect that a request change in line 2 would override
/// the change in line 3 and this is definitely not what you would expect.
/// The solution here is to collect the request mutations and apply them in reversed order
/// when `finalize()` is invoked to build the performed `URLRequest`.
extension HTTPCallConfiguration {
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
    var request = URLRequest(url: URL(string: "/")!)
    for requestUpdate in requestUpdates.reversed() {
      request = try requestUpdate(request)
    }
    return request
  }
}
