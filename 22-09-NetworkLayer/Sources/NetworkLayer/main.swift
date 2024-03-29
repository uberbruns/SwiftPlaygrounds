import Foundation


@available(macOS 12.0, *)
extension HTTPCall {
  static func starWars<D: Decodable>(path: String, decoding: D.Type) -> HTTPCall<D> {
    var request = URLRequest(url: URL(string: "https://swapi.dev")!)
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.url?.appendPathComponent("api")
    request.url?.appendPathComponent(path)
    request.networkServiceType = .responsiveData

    return HTTPCall<D>(
      request: request,
      decode: { try JSONDecoder().decode(D.self, from: $0) }
    )
  }
}



@available(macOS 12.0, *)
extension HTTPCall {

  static func moia(host: (String) -> String) -> HTTPCall<Data> {
    .init(url: URL(string: host("dev"))!)
  }

  static var tripHandling: HTTPCall<Data> {
    .moia(host: { "https://trip-handling.trip.\($0).moia-group.io" })
  }

  static var cancellationFeedback: HTTPCall<PersonMessage> {
    .tripHandling
    .path("cancellation/feedback")
    .method(.get)
    .decodeResponse(as: PersonMessage.self)
  }
}


struct WookieModifier: HTTPExecutionModifier {
  func modify(request: URLRequest, context: HTTPCallContext, execute: (URLRequest) async throws -> (Data, HTTPURLResponse)) async throws -> (Data, HTTPURLResponse) {
    let (data, urlResponse) = try await execute(request)
    let text = String(data: data, encoding: .utf8)!
      .replacingOccurrences(of: "u", with: "ooohooo")
    return (text.data(using: .utf8)!, urlResponse)
  }
}


struct LoggingHTTPExecutionModifier: HTTPExecutionModifier {
  func modify(request: URLRequest, context: HTTPCallContext, execute: (URLRequest) async throws -> (Data, HTTPURLResponse)) async throws -> (Data, HTTPURLResponse) {
    do {
      log("Executing", for: request)
      let (data, response) = try await execute(request)
      switch response.statusCode {
      case 100 ... 199:
        log("Unexpected Information Response", for: request, and: response, body: data)
      case 200 ... 299:
        log("Succeeded", for: request, and: response)
      case 300 ... 399:
        log("Unhandled Redirection", for: request, and: response, body: data)
      case 400 ... 499:
        log("Client Error", for: request, and: response, body: data)
      case 500 ... 599:
        log("Server Error", for: request, and: response, body: data)
      default:
        log("Unknown Status Code", for: request, and: response, body: data)
      }
      return (data, response)
    } catch {
      throw error
    }
  }

  private func log(_ message: String, for request: URLRequest, and response: HTTPURLResponse? = nil, body: Data? = nil) {
    let tags: [String?] = [
      "HTTP_CALL",
      request.httpMethod,
    ]

    let messages: [String?] = [
      "Calling '\(request.url!)' ->",
      message,
      response.map { "(\($0.statusCode))" },
    ]

    print(
      tags.compactMap({ $0 }).map({ "[\($0)]" }).joined()
      + " "
      + messages.compactMap({ $0 }).joined(separator: " ")
    )

    if let body {
      let string = String(data: body, encoding: .utf8)!
      print(string)
    }
  }
}



@available(macOS 12.0, *)
final class StarWarsBackendService: HTTPBackendService {
  func getPerson(id: Int) async throws -> Person {
    let (person, _) = try await execute(call: .starWars(path: "people/\(id)/", decoding: Person.self))
    return person
  }

  override func execute<ResponseContent, ExecutionModifier>(call: HTTPCall<ResponseContent>, modifier: ExecutionModifier) async throws -> (ResponseContent, HTTPURLResponse) where ExecutionModifier : HTTPExecutionModifier {
    try await super.execute(
      call: call,
      modifier: modifier
        .add(LoggingHTTPExecutionModifier())
        .add(WookieModifier())
    )
  }
}


struct Person: Codable {
  let name: String
}


struct PersonMessage: Codable, Message {
  let name: String

  init(data: Data) throws {
    self = try JSONDecoder().decode(Self.self, from: data)
  }
}


if #available(macOS 12.0, *) {
  Task {
    let httpService = StarWarsBackendService()
    let person = try! await httpService.getPerson(id: 1)
    print(person)
    exit(0)
  }
  RunLoop.main.run()
}


protocol Message {
  init(data: Data) throws
}
