import XCTest
@testable import SwiftyMath

final class SupportingFunctionsTests: XCTestCase {

  func test0() throws {
    let fibonacciNumbers = FibonacciNumbers(count: 0)
    XCTAssertEqual(fibonacciNumbers.sequence, [])
  }

  func test1() throws {
    let fibonacciNumbers = FibonacciNumbers(count: 1)
    XCTAssertEqual(fibonacciNumbers.sequence, [0])
  }

  func test2() throws {
    let fibonacciNumbers = FibonacciNumbers(count: 2)
    XCTAssertEqual(fibonacciNumbers.sequence, [0, 1])
  }

  func test3() throws {
    let fibonacciNumbers = FibonacciNumbers(count: 3)
    XCTAssertEqual(fibonacciNumbers.sequence, [0, 1, 1])
  }

  func test4() throws {
    let fibonacciNumbers = FibonacciNumbers(count: 13)
    XCTAssertEqual(fibonacciNumbers.sequence, [0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144])
  }
}
