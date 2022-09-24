import Foundation
import SwiftUI

@available(macOS 11.3, *)
public struct HTTP3RequestModifier<ResponseBody>: HTTPCallModifier  {
  public func call(configuration: HTTPCallConfiguration, execute: (HTTPCallConfiguration) async throws -> (ResponseBody, URLResponse)) async throws -> (ResponseBody, URLResponse) {
    var configuration = configuration
    configuration.add { request in
      request.assumesHTTP3Capable = true
    }
    return try await execute(configuration)
  }
}


@available(macOS 11.3, *)
extension HTTPCall {
  var http3: some HTTPCall {
    modifier(HTTP3RequestModifier())
  }
}
