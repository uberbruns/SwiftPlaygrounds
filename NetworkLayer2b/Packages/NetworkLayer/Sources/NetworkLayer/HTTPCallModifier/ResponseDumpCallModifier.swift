import Foundation


public struct ResponseDumpModifier: HTTPCallModifier {
  let enabled: Bool

  public func call(configuration: HTTPCallConfiguration, execute: (HTTPCallConfiguration) async throws -> (Data, HTTPURLResponse)) async throws -> (Data, HTTPURLResponse) {
    let (body, response) = try await execute(configuration)
    if enabled, let string = String(data: body, encoding: .utf8) {
      print(response.allHeaderFields)
      print(string)
    }
    return (body, response)
  }
}


public extension HTTPCall where ResponseBody == Data {
  func responseDump(enabled: Bool) -> some HTTPCall<Data> {
    modifier(ResponseDumpModifier(enabled: enabled))
  }
}
