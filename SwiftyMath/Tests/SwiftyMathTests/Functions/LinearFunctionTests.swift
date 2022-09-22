import XCTest
@testable import SwiftyMath

final class LinearFunctionTests: XCTestCase {
  func test() throws {
    let solution = LinearFunction(firstPoint: CGPoint(x: 3, y: 2), secondPoint: CGPoint(x: 7, y: -4))
    XCTAssertEqual(solution.a, -1.5)
    XCTAssertEqual(solution.b, 6.5)
  }

  func testIntersection() throws {
    let functionA = LinearFunction(a: 2, b: 3)
    let functionB = LinearFunction(a: -0.5, b: 7)
    let intersection = functionA.pointOfIntersection(with: functionB)
    XCTAssertEqual(intersection.x, 1.6)
    XCTAssertEqual(intersection.y, 6.2)
  }
}
