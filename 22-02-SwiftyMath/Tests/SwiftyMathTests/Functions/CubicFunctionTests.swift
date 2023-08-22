import XCTest
@testable import SwiftyMath

final class CubicFunctionTests: XCTestCase {
  func test() throws {
    let function = CubicFunction(a: 1, b: -3, c: -144, d: 432)

    // X-Intercepts
    XCTAssertEqual(function.roots.0, -12, accuracy: 100.ulp)
    XCTAssertEqual(try XCTUnwrap(function.roots.1), 3, accuracy: 100.ulp)
    XCTAssertEqual(try XCTUnwrap(function.roots.2), 12, accuracy: 100.ulp)

    // Turning Points
    XCTAssertEqual(function.turningPoints.0, CGPoint(x: -6, y: 972))
    XCTAssertEqual(function.turningPoints.1, CGPoint(x: 8, y: -400))

    // Inflection Point
    XCTAssertEqual(function.inflectionPoint, CGPoint(x: 1, y: 286))
  }
}
