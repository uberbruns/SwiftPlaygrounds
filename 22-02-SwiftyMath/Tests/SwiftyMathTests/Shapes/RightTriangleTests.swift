import XCTest
@testable import SwiftyMath

final class RightTriangleTests: XCTestCase {
  func test1() throws {
    let triangle = RightTriangle(a: 3, b: 4)
    XCTAssertEqual(triangle.a, 3, accuracy: 0.0001)
    XCTAssertEqual(triangle.b, 4, accuracy: 0.0001)
    XCTAssertEqual(triangle.c, 5, accuracy: 0.0001)
    XCTAssertEqual(triangle.alpha.degrees, 36.8698976, accuracy: 0.0001)
    XCTAssertEqual(triangle.beta.degrees, 53.1301023541, accuracy: 0.0001)
    XCTAssertEqual(triangle.gamma.degrees, 90, accuracy: 0.0001)
    XCTAssertEqual(triangle.area, 6, accuracy: 0.0001)
    XCTAssertEqual(triangle.height, 2.4, accuracy: 0.0001)
    XCTAssertEqual(triangle.height, triangle.altitudeToC, accuracy: 0.0001)
    XCTAssertEqual(triangle.perimeter, 12, accuracy: 0.0001)
    XCTAssertEqual(triangle.semiperimeter, 6, accuracy: 0.0001)
  }

  func test2() throws {
    let triangle = RightTriangle(alpha: .degrees(36.8698976), area: 6)
    XCTAssertEqual(triangle.a, 3, accuracy: 0.0001)
    XCTAssertEqual(triangle.b, 4, accuracy: 0.0001)
  }
}
