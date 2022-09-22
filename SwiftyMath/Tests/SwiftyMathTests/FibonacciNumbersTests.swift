import XCTest
@testable import SwiftyMath

final class FibonacciNumbersTests: XCTestCase {

  func test() throws {
    XCTAssertEqual(translate(10, from: 5...15, to: 20...30), 25)

    XCTAssertEqual(clamp(90, to: 25...50), 50)
    XCTAssertEqual(clamp(0, to: 25...50), 25)
    XCTAssertEqual(clamp(90, to: 25...), 90)
    XCTAssertEqual(clamp(90, to: ...50), 50)
    XCTAssertEqual(clamp(0, to: ...50), 0)
    XCTAssertEqual(clamp(0, to: 25...), 25)
  }
}
