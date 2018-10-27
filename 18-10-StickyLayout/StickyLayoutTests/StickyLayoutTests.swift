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
        let items = [FillLayout.Item(for: "A", height: 10, alignment: .top)]
        let positionings = FillLayout.positionings(for: items, inside: CGRect(x: 0, y: 0, width: 100, height: 100), offset: 0)
        XCTAssertEqual(positionings[0].frame, CGRect(x: 0, y: 0, width: 100, height: 10))
    }

    func testMultipleParameter() {
        let items = [
            FillLayout.Item(for: "A", height: 10, alignment: .top),
            FillLayout.Item(for: "B", height: 10, alignment: .top)
        ]

        let positionings = FillLayout.positionings(for: items, inside: CGRect(x: 0, y: 0, width: 100, height: 100), offset: 0)
        XCTAssertEqual(positionings[0].frame, CGRect(x: 0, y: 0, width: 100, height: 10))
        XCTAssertEqual(positionings[1].frame, CGRect(x: 0, y: 10, width: 100, height: 10))
    }

    func testOffset() {
        let items = [
            FillLayout.Item(for: "A", height: 10, alignment: .top),
            FillLayout.Item(for: "B", height: 10, alignment: .top)
        ]

        let positionings = FillLayout.positionings(for: items, inside: CGRect(x: 0, y: 0, width: 100, height: 100), offset: 50)
        XCTAssertEqual(positionings[0].frame, CGRect(x: 0, y: -50, width: 100, height: 10))
        XCTAssertEqual(positionings[1].frame, CGRect(x: 0, y: -40, width: 100, height: 10))
    }

    func testFlexibleSizeAlignment() {
        let items = [
            FillLayout.Item(for: "A", height: 10, alignment: .top),
            FillLayout.Item(for: "B", height: 10, alignment: .flexible)
        ]

        let positionings = FillLayout.positionings(for: items, inside: CGRect(x: 0, y: 0, width: 100, height: 100), offset: 0)
        XCTAssertEqual(positionings[0].frame, CGRect(x: 0, y: 0, width: 100, height: 10))
        XCTAssertEqual(positionings[1].frame, CGRect(x: 0, y: 10, width: 100, height: 90))
    }

    func testCenterAlignment() {
        let items = [
            FillLayout.Item(for: "A", height: 0, alignment: .flexible),
            FillLayout.Item(for: "B", height: 20, alignment: .top),
            FillLayout.Item(for: "C", height: 0, alignment: .flexible),
        ]

        let positionings = FillLayout.positionings(for: items, inside: CGRect(x: 0, y: 0, width: 100, height: 100), offset: 0)
        XCTAssertEqual(positionings[0].frame, CGRect(x: 0, y: 0, width: 100, height: 40))
        XCTAssertEqual(positionings[1].frame, CGRect(x: 0, y: 40, width: 100, height: 20))
        XCTAssertEqual(positionings[2].frame, CGRect(x: 0, y: 60, width: 100, height: 40))
    }

    func testBottomAlignment() {
        let items = [
            FillLayout.Item(for: "A", height: 20, alignment: .top),
            FillLayout.Item(for: "B", height: 20, alignment: .bottom),
            FillLayout.Item(for: "C", height: 20, alignment: .bottom),
        ]

        let positionings = FillLayout.positionings(for: items, inside: CGRect(x: 0, y: 0, width: 100, height: 100), offset: 0)
        XCTAssertEqual(positionings[0].frame, CGRect(x: 0, y: 0, width: 100, height: 20))
        XCTAssertEqual(positionings[1].frame, CGRect(x: 0, y: 60, width: 100, height: 20))
        XCTAssertEqual(positionings[2].frame, CGRect(x: 0, y: 80, width: 100, height: 20))
    }

    func testMixedAlignment() {
        let items = [
            FillLayout.Item(for: "A", height: 20, alignment: .top),
            FillLayout.Item(for: "B", height: 20, alignment: .flexible),
            FillLayout.Item(for: "C", height: 20, alignment: .bottom),
        ]

        let positionings = FillLayout.positionings(for: items, inside: CGRect(x: 0, y: 0, width: 100, height: 100), offset: 0)
        XCTAssertEqual(positionings[0].frame, CGRect(x: 0, y: 0, width: 100, height: 20))
        XCTAssertEqual(positionings[1].frame, CGRect(x: 0, y: 20, width: 100, height: 60))
        XCTAssertEqual(positionings[2].frame, CGRect(x: 0, y: 80, width: 100, height: 20))
    }

    func testMixedCenteringAlignment() {
        let items = [
            FillLayout.Item(for: "A", height: 20, alignment: .top),
            FillLayout.Item(for: "B1", height: 20, alignment: .flexible),
            FillLayout.Item(for: "B2", height: 0, alignment: .flexible),
            FillLayout.Item(for: "C", height: 20, alignment: .bottom),
        ]

        let positionings = FillLayout.positionings(for: items, inside: CGRect(x: 0, y: 0, width: 100, height: 100), offset: 0)
        XCTAssertEqual(positionings[0].frame, CGRect(x: 0, y: 0, width: 100, height: 20))
        XCTAssertEqual(positionings[1].frame, CGRect(x: 0, y: 20, width: 100, height: 40))
        XCTAssertEqual(positionings[2].frame, CGRect(x: 0, y: 60, width: 100, height: 20))
        XCTAssertEqual(positionings[3].frame, CGRect(x: 0, y: 80, width: 100, height: 20))
    }
}
