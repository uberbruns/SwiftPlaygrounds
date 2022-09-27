import Foundation


@available(macOS 10.15, *)
public struct DigestAuthorizationCallModifier<ResponseBody>: HTTPCallModifier {
  let username: String
  let password: String

  public func call(configuration: HTTPCallConfiguration, execute: (HTTPCallConfiguration) async throws -> (ResponseBody, HTTPURLResponse)) async throws -> (ResponseBody, HTTPURLResponse) {
    let (responseBody, response) = try await execute(configuration)
    if response.standardStatusCode == .unauthorized {
      return try await execute(
        configuration.addingRequestMutation { nonFinalRequest in
          _ = nonFinalRequest.setDigestAuthorizationHeader(
            username: username,
            password: password,
            request: try configuration.finalize(),
            response: response
          )
        }
      )
    } else {
      return (responseBody, response)
    }
  }
}

@available(macOS 10.15, *)
public extension HTTPCall {
  func digestAuthorization(username: String, password: String) -> some HTTPCall<ResponseBody> {
    modifier(DigestAuthorizationCallModifier(username: username, password: password))
  }
}
