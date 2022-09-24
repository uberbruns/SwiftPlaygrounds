import Foundation
import SwiftUI

@available(macOS 11.3, *)
public struct HTTP3RequestModifier<ResponseBody>: HTTPCallModifier  {
  public func call(request: URLRequest, execute: (URLRequest) async throws -> (ResponseBody, URLResponse)) async throws -> (ResponseBody, URLResponse) {
    var request = request
    request.assumesHTTP3Capable = true
    return try await execute(request)
  }
}


@available(macOS 11.3, *)
extension HTTPCall {
  var http3: some HTTPCall {
    modifier(HTTP3RequestModifier())
  }
}
