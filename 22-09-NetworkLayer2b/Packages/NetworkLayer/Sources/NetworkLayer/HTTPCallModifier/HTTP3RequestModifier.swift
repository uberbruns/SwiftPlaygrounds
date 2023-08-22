import Foundation


@available(macOS 11.3, *)
public struct HTTP3RequestModifier<ResponseBody>: HTTPCallModifier  {
  public func call(configuration: HTTPCallConfiguration, execute: (HTTPCallConfiguration) async throws -> (ResponseBody, HTTPURLResponse)) async throws -> (ResponseBody, HTTPURLResponse) {
    try await execute(configuration.addingRequestMutation { request in
      if #available(iOS 14.5, *) {
        request.assumesHTTP3Capable = true
      }
    })
  }
}


@available(macOS 11.3, *)
public extension HTTPCall {
  var http3: some HTTPCall<ResponseBody> {
    modifier(HTTP3RequestModifier())
  }
}
