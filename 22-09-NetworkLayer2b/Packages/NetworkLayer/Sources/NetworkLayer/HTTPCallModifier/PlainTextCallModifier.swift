import Foundation


public struct PlainTextCallModifier: HTTPCallModifier {
  public func call(configuration: HTTPCallConfiguration, execute: (HTTPCallConfiguration) async throws -> (Data, HTTPURLResponse)) async throws -> (String, HTTPURLResponse) {
    let (body, response) = try await execute(configuration)
    guard let plainText = String(data: body, encoding: .utf8) else { throw HTTPCallError.PlainText.invalidUTF8 }
    return (plainText, response)
  }
}


public extension HTTPCall where ResponseBody == Data {
  func plainText() -> some HTTPCall<String> {
    modifier(PlainTextCallModifier())
  }
}


public extension HTTPCallError {
  enum PlainText: Error {
    case invalidUTF8
  }
}
