import XCTest
@testable import SwiftyMath

final class RectangleTests: XCTestCase {
  func test1() throws {
    let rectangle = Rectangle(a: 5, b: 4)
    XCTAssertEqual(rectangle.a, 5, accuracy: 0.0001)
    XCTAssertEqual(rectangle.b, 4, accuracy: 0.0001)
    XCTAssertEqual(rectangle.area, 20, accuracy: 0.0001)
    XCTAssertEqual(rectangle.diagonal, 6.4031242374328485, accuracy: 0.0001)
    XCTAssertEqual(rectangle.ratio, 1.25, accuracy: 0.0001)
    XCTAssertEqual(rectangle.perimeter, 18, accuracy: 0.0001)
    XCTAssertEqual(rectangle.angle.degrees, 38.65980, accuracy: 0.0001)
  }

  func test2() throws {
    let rectangle = Rectangle(ratio: 1.25, area: 20)
    XCTAssertEqual(rectangle.a, 5, accuracy: 0.0001)
    XCTAssertEqual(rectangle.b, 4, accuracy: 0.0001)
  }

  func test3() throws {
    let rectangle = Rectangle(a: 5, perimeter: 18)
    XCTAssertEqual(rectangle.a, 5, accuracy: 0.0001)
    XCTAssertEqual(rectangle.b, 4, accuracy: 0.0001)
  }

  func test4() throws {
    let rectangle = Rectangle(b: 4, perimeter: 18)
    XCTAssertEqual(rectangle.a, 5, accuracy: 0.0001)
    XCTAssertEqual(rectangle.b, 4, accuracy: 0.0001)
  }

  func test5() throws {
    let rectangle = Rectangle(ratio: 1.25, perimeter: 18)
    XCTAssertEqual(rectangle.a, 5, accuracy: 0.0001)
    XCTAssertEqual(rectangle.b, 4, accuracy: 0.0001)
  }

  func test6() throws {
    let rectangle = Rectangle(perimeter: 18, angle: .degrees(38.65980))
    XCTAssertEqual(rectangle.a, 5, accuracy: 0.0001)
    XCTAssertEqual(rectangle.b, 4, accuracy: 0.0001)
  }

  func test7() throws {
    let rectangle = Rectangle(area: 20, angle: .degrees(38.65980))
    XCTAssertEqual(rectangle.a, 5, accuracy: 0.0001)
    XCTAssertEqual(rectangle.b, 4, accuracy: 0.0001)
  }
}
