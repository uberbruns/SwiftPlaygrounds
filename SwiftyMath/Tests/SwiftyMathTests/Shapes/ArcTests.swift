import XCTest
@testable import SwiftyMath

final class ArcTests: XCTestCase {
  func test1() throws {
    let arc = CircularArc(centralAngle: .degrees(42), radius: 23)
    XCTAssertEqual(arc.centralAngle.degrees, 42, accuracy: 0.0001)
    XCTAssertEqual(arc.radius, 23, accuracy: 0.0001)
    XCTAssertEqual(arc.diameter, 46, accuracy: 0.0001)
    XCTAssertEqual(arc.sectorArea, 193.8886, accuracy: 0.0001)
    XCTAssertEqual(arc.chordLength, 16.485, accuracy: 0.0001)
    XCTAssertEqual(arc.arcLength, 16.85988, accuracy: 0.0001)
  }

  func test2() throws {
    let arc = CircularArc(centralAngle: .degrees(42), sectorArea: 193.8886)
    XCTAssertEqual(arc.centralAngle.degrees, 42, accuracy: 0.0001)
    XCTAssertEqual(arc.radius, 23, accuracy: 0.0001)
    XCTAssertEqual(arc.diameter, 46, accuracy: 0.0001)
    XCTAssertEqual(arc.sectorArea, 193.8886, accuracy: 0.0001)
    XCTAssertEqual(arc.chordLength, 16.485, accuracy: 0.0001)
    XCTAssertEqual(arc.arcLength, 16.85988, accuracy: 0.0001)
  }

  func test3() throws {
    let arc = CircularArc(radius: 23, arcLength: 16.85988)
    XCTAssertEqual(arc.centralAngle.degrees, 42, accuracy: 0.0001)
    XCTAssertEqual(arc.radius, 23, accuracy: 0.0001)
    XCTAssertEqual(arc.diameter, 46, accuracy: 0.0001)
    XCTAssertEqual(arc.sectorArea, 193.8886, accuracy: 0.0001)
    XCTAssertEqual(arc.chordLength, 16.485, accuracy: 0.0001)
    XCTAssertEqual(arc.arcLength, 16.85988, accuracy: 0.0001)
  }
}
