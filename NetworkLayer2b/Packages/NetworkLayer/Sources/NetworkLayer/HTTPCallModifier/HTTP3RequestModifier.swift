import Foundation
import SwiftUI

@available(macOS 11.3, *)
public struct HTTP3RequestModifier<ResponseBody>: HTTPCallModifier  {
  public func call(configuration: HTTPCallConfiguration, execute: (HTTPCallConfiguration) async throws -> (ResponseBody, HTTPURLResponse)) async throws -> (ResponseBody, HTTPURLResponse) {
    try await execute(configuration.addingRequestMutation { request in
      request.assumesHTTP3Capable = true
    })
  }
}


@available(macOS 11.3, *)
extension HTTPCall {
  var http3: some HTTPCall<ResponseBody> {
    modifier(HTTP3RequestModifier())
  }
}
