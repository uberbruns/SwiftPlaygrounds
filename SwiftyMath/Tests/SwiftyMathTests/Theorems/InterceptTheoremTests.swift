import XCTest
@testable import SwiftyMath

final class InterceptTheoremTests: XCTestCase {

  func test() throws {
    let solution = InterceptTheorem(
      knownLine: .segmentLength(first: 2, second: 4),
      unsolvedLine: .segmentLength(first: 3)
    )
    XCTAssertEqual(solution.solvedLine.firstSegment, 3)
    XCTAssertEqual(solution.solvedLine.secondSegment, 6)
    XCTAssertEqual(solution.solvedLine.sum, 9)
  }
}
