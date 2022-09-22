import Foundation


// Based upon: https://github.com/apple/swift-nio/blob/2.26.0/Sources/NIOHTTP1/HTTPTypes.swift

/// A HTTP response status code.
public enum StandardHTTPStatusCode: Equatable {
  case custom(value: Int)

  // 1xx
  case `continue`
  case switchingProtocols
  case processing
  case earlyHints

  // 2xx
  case ok
  case created
  case accepted
  case nonAuthoritativeInformation
  case noContent
  case resetContent
  case partialContent
  case multiStatus
  case alreadyReported
  case iAmUsed

  // 3xx
  case multipleChoices
  case movedPermanently
  case found
  case seeOther
  case notModified
  case useProxy
  case temporaryRedirect
  case permanentRedirect

  // 4xx
  case badRequest
  case unauthorized
  case paymentRequired
  case forbidden
  case notFound
  case methodNotAllowed
  case notAcceptable
  case proxyAuthenticationRequired
  case requestTimeout
  case conflict
  case gone
  case lengthRequired
  case preconditionFailed
  case payloadTooLarge
  case uriTooLong
  case unsupportedMediaType
  case rangeNotSatisfiable
  case expectationFailed
  case iAmATeapot
  case misdirectedRequest
  case unprocessableEntity
  case locked
  case failedDependency
  case upgradeRequired
  case preconditionRequired
  case tooManyRequests
  case requestHeaderFieldsTooLarge
  case unavailableForLegalReasons

  // 5xx
  case internalServerError
  case notImplemented
  case badGateway
  case serviceUnavailable
  case gatewayTimeout
  case httpVersionNotSupported
  case variantAlsoNegotiates
  case insufficientStorage
  case loopDetected
  case notExtended
  case networkAuthenticationRequired
}


public extension HTTPURLResponse {
  /// The numerical status code for a given HTTP response status.
  var standardStatusCode: StandardHTTPStatusCode {
    switch statusCode {
    case 100:
      return .`continue`
    case 101:
      return .switchingProtocols
    case 102:
      return .processing
    case 103:
      return .earlyHints
    case 200:
      return .ok
    case 201:
      return .created
    case 202:
      return .accepted
    case 203:
      return .nonAuthoritativeInformation
    case 204:
      return .noContent
    case 205:
      return .resetContent
    case 206:
      return .partialContent
    case 207:
      return .multiStatus
    case 208:
      return .alreadyReported
    case 226:
      return .iAmUsed
    case 300:
      return .multipleChoices
    case 301:
      return .movedPermanently
    case 302:
      return .found
    case 303:
      return .seeOther
    case 304:
      return .notModified
    case 305:
      return .useProxy
    case 307:
      return .temporaryRedirect
    case 308:
      return .permanentRedirect
    case 400:
      return .badRequest
    case 401:
      return .unauthorized
    case 402:
      return .paymentRequired
    case 403:
      return .forbidden
    case 404:
      return .notFound
    case 405:
      return .methodNotAllowed
    case 406:
      return .notAcceptable
    case 407:
      return .proxyAuthenticationRequired
    case 408:
      return .requestTimeout
    case 409:
      return .conflict
    case 410:
      return .gone
    case 411:
      return .lengthRequired
    case 412:
      return .preconditionFailed
    case 413:
      return .payloadTooLarge
    case 414:
      return .uriTooLong
    case 415:
      return .unsupportedMediaType
    case 416:
      return .rangeNotSatisfiable
    case 417:
      return .expectationFailed
    case 418:
      return .iAmATeapot
    case 421:
      return .misdirectedRequest
    case 422:
      return .unprocessableEntity
    case 423:
      return .locked
    case 424:
      return .failedDependency
    case 426:
      return .upgradeRequired
    case 428:
      return .preconditionRequired
    case 429:
      return .tooManyRequests
    case 431:
      return .requestHeaderFieldsTooLarge
    case 451:
      return .unavailableForLegalReasons
    case 500:
      return .internalServerError
    case 501:
      return .notImplemented
    case 502:
      return .badGateway
    case 503:
      return .serviceUnavailable
    case 504:
      return .gatewayTimeout
    case 505:
      return .httpVersionNotSupported
    case 506:
      return .variantAlsoNegotiates
    case 507:
      return .insufficientStorage
    case 508:
      return .loopDetected
    case 510:
      return .notExtended
    case 511:
      return .networkAuthenticationRequired
    default:
      return .custom(value: statusCode)
    }
  }
}
