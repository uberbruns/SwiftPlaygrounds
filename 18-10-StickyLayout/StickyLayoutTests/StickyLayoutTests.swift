//
//  StickyLayoutTests.swift
//  StickyLayoutTests
//
//  Created by Karsten Bruns on 26.10.18.
//  Copyright © 2018 bruns.me. All rights reserved.
//

import Foundation
import XCTest
@testable import StickyLayout

class StickyLayoutTests: XCTestCase {

    override func setUp() {
    }

    override func tearDown() {
    }

    func testOneParameter() {
        let items = [CollectionViewFillLayout.Item(with: "A", height: 10, alignment: .default)]
        let result = CollectionViewFillLayout.solve(with: items, inside: CGRect(x: 0, y: 0, width: 100, height: 100), offset: 0)
        XCTAssertEqual(result.positionings[0].frame, CGRect(x: 0, y: 0, width: 100, height: 10))
    }

    func testMultipleParameter() {
        let items = [
            CollectionViewFillLayout.Item(with: "A", height: 10, alignment: .default),
            CollectionViewFillLayout.Item(with: "B", height: 10, alignment: .default)
        ]

        let result = CollectionViewFillLayout.solve(with: items, inside: CGRect(x: 0, y: 0, width: 100, height: 100), offset: 0)
        XCTAssertEqual(result.positionings[0].frame, CGRect(x: 0, y: 0, width: 100, height: 10))
        XCTAssertEqual(result.positionings[1].frame, CGRect(x: 0, y: 10, width: 100, height: 10))
    }

    func testOffset() {
        let items = [
            CollectionViewFillLayout.Item(with: "A", height: 10, alignment: .default),
            CollectionViewFillLayout.Item(with: "B", height: 10, alignment: .default)
        ]

        let result = CollectionViewFillLayout.solve(with: items, inside: CGRect(x: 0, y: 0, width: 100, height: 100), offset: 50)
        XCTAssertEqual(result.positionings[0].frame, CGRect(x: 0, y: -50, width: 100, height: 10))
        XCTAssertEqual(result.positionings[1].frame, CGRect(x: 0, y: -40, width: 100, height: 10))
    }

    func testFlexibleSizeAlignment() {
        let items = [
            CollectionViewFillLayout.Item(with: "A", height: 10, alignment: .default),
            CollectionViewFillLayout.Item(with: "B", height: 10, alignment: .flexible)
        ]

        let result = CollectionViewFillLayout.solve(with: items, inside: CGRect(x: 0, y: 0, width: 100, height: 100), offset: 0)
        XCTAssertEqual(result.positionings[0].frame, CGRect(x: 0, y: 0, width: 100, height: 10))
        XCTAssertEqual(result.positionings[1].frame, CGRect(x: 0, y: 10, width: 100, height: 90))
    }

    func testCenterAlignment() {
        let items = [
            CollectionViewFillLayout.Item(with: "A", height: 0, alignment: .flexible),
            CollectionViewFillLayout.Item(with: "B", height: 20, alignment: .default),
            CollectionViewFillLayout.Item(with: "C", height: 0, alignment: .flexible),
        ]

        let result = CollectionViewFillLayout.solve(with: items, inside: CGRect(x: 0, y: 0, width: 100, height: 100), offset: 0)
        XCTAssertEqual(result.positionings[0].frame, CGRect(x: 0, y: 0, width: 100, height: 40))
        XCTAssertEqual(result.positionings[1].frame, CGRect(x: 0, y: 40, width: 100, height: 20))
        XCTAssertEqual(result.positionings[2].frame, CGRect(x: 0, y: 60, width: 100, height: 40))
    }

    func testBottomAlignment() {
        let items = [
            CollectionViewFillLayout.Item(with: "A", height: 20, alignment: .default),
            CollectionViewFillLayout.Item(with: "B", height: 20, alignment: .stickyBottom),
            CollectionViewFillLayout.Item(with: "C", height: 20, alignment: .stickyBottom),
        ]

        let result = CollectionViewFillLayout.solve(with: items, inside: CGRect(x: 0, y: 0, width: 100, height: 100), offset: 0)
        XCTAssertEqual(result.positionings[0].frame, CGRect(x: 0, y: 0, width: 100, height: 20))
        XCTAssertEqual(result.positionings[1].frame, CGRect(x: 0, y: 60, width: 100, height: 20))
        XCTAssertEqual(result.positionings[2].frame, CGRect(x: 0, y: 80, width: 100, height: 20))
    }

    func testMixedAlignment() {
        let items = [
            CollectionViewFillLayout.Item(with: "A", height: 20, alignment: .default),
            CollectionViewFillLayout.Item(with: "B", height: 20, alignment: .flexible),
            CollectionViewFillLayout.Item(with: "C", height: 20, alignment: .stickyBottom),
        ]

        let result = CollectionViewFillLayout.solve(with: items, inside: CGRect(x: 0, y: 0, width: 100, height: 100), offset: 0)
        XCTAssertEqual(result.positionings[0].frame, CGRect(x: 0, y: 0, width: 100, height: 20))
        XCTAssertEqual(result.positionings[1].frame, CGRect(x: 0, y: 20, width: 100, height: 60))
        XCTAssertEqual(result.positionings[2].frame, CGRect(x: 0, y: 80, width: 100, height: 20))
    }

    func testMixedCenteringAlignment() {
        let items = [
            CollectionViewFillLayout.Item(with: "A", height: 20, alignment: .default),
            CollectionViewFillLayout.Item(with: "B1", height: 20, alignment: .flexible),
            CollectionViewFillLayout.Item(with: "B2", height: 0, alignment: .flexible),
            CollectionViewFillLayout.Item(with: "C", height: 20, alignment: .stickyBottom),
        ]

        let result = CollectionViewFillLayout.solve(with: items, inside: CGRect(x: 0, y: 0, width: 100, height: 100), offset: 0)
        XCTAssertEqual(result.positionings[0].frame, CGRect(x: 0, y: 0, width: 100, height: 20))
        XCTAssertEqual(result.positionings[1].frame, CGRect(x: 0, y: 20, width: 100, height: 40))
        XCTAssertEqual(result.positionings[2].frame, CGRect(x: 0, y: 60, width: 100, height: 20))
        XCTAssertEqual(result.positionings[3].frame, CGRect(x: 0, y: 80, width: 100, height: 20))
    }


    func testLazyMapping() {
        let numbers = 0..<100
        var iterations = 0

        let items = numbers.lazy.map { (number: Int) -> CollectionViewFillLayout.Item<Int> in
            iterations += 1
            return CollectionViewFillLayout.Item(with: number, height: 20, alignment: .default)
        }

        XCTAssertEqual(iterations, 0)
        let result = CollectionViewFillLayout.solve(with: items, inside: CGRect(x: 0, y: 0, width: 100, height: 100), offset: 0)
        XCTAssertEqual(iterations, 100)
        XCTAssertEqual(result.positionings.last?.frame.maxY, CGFloat(20 * numbers.count))
    }
}
