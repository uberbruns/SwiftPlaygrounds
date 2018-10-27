//
//  StickyLayoutTests.swift
//  StickyLayoutTests
//
//  Created by Karsten Bruns on 26.10.18.
//  Copyright © 2018 bruns.me. All rights reserved.
//

import XCTest
@testable import StickyLayout

class StickyLayoutTests: XCTestCase {

    override func setUp() {
    }

    override func tearDown() {
    }

    func testOneParameter() {
        let parameters = [Parameter(element: "A", height: 10, alignment: .top)]
        let positionings = Resolver().resolve(parameters: parameters, bounds: CGRect(x: 0, y: 0, width: 100, height: 100), offset: 0)
        XCTAssertEqual(positionings[0].frame, CGRect(x: 0, y: 0, width: 100, height: 10))
    }

    func testMultipleParameter() {
        let parameters = [
            Parameter(element: "A", height: 10, alignment: .top),
            Parameter(element: "B", height: 10, alignment: .top)
        ]

        let positionings = Resolver().resolve(parameters: parameters, bounds: CGRect(x: 0, y: 0, width: 100, height: 100), offset: 0)
        XCTAssertEqual(positionings[0].frame, CGRect(x: 0, y: 0, width: 100, height: 10))
        XCTAssertEqual(positionings[1].frame, CGRect(x: 0, y: 10, width: 100, height: 10))
    }

    func testOffset() {
        let parameters = [
            Parameter(element: "A", height: 10, alignment: .top),
            Parameter(element: "B", height: 10, alignment: .top)
        ]

        let positionings = Resolver().resolve(parameters: parameters, bounds: CGRect(x: 0, y: 0, width: 100, height: 100), offset: 50)
        XCTAssertEqual(positionings[0].frame, CGRect(x: 0, y: -50, width: 100, height: 10))
        XCTAssertEqual(positionings[1].frame, CGRect(x: 0, y: -40, width: 100, height: 10))
    }

    func testFlexibleSizeAlignment() {
        let parameters = [
            Parameter(element: "A", height: 10, alignment: .top),
            Parameter(element: "B", height: 10, alignment: .flexibleSize)
        ]

        let positionings = Resolver().resolve(parameters: parameters, bounds: CGRect(x: 0, y: 0, width: 100, height: 100), offset: 0)
        XCTAssertEqual(positionings[0].frame, CGRect(x: 0, y: 0, width: 100, height: 10))
        XCTAssertEqual(positionings[1].frame, CGRect(x: 0, y: 10, width: 100, height: 90))
    }

    func testCenterAlignment() {
        let parameters = [
            Parameter(element: "A", height: 0, alignment: .flexibleSize),
            Parameter(element: "B", height: 20, alignment: .top),
            Parameter(element: "C", height: 0, alignment: .flexibleSize),
        ]

        let positionings = Resolver().resolve(parameters: parameters, bounds: CGRect(x: 0, y: 0, width: 100, height: 100), offset: 0)
        XCTAssertEqual(positionings[0].frame, CGRect(x: 0, y: 0, width: 100, height: 40))
        XCTAssertEqual(positionings[1].frame, CGRect(x: 0, y: 40, width: 100, height: 20))
        XCTAssertEqual(positionings[2].frame, CGRect(x: 0, y: 60, width: 100, height: 40))
    }

    func testTrailingAlignment() {
        let parameters = [
            Parameter(element: "A", height: 20, alignment: .top),
            Parameter(element: "B", height: 20, alignment: .bottom),
            Parameter(element: "C", height: 20, alignment: .bottom),
        ]

        let positionings = Resolver().resolve(parameters: parameters, bounds: CGRect(x: 0, y: 0, width: 100, height: 100), offset: 0)
        XCTAssertEqual(positionings[0].frame, CGRect(x: 0, y: 0, width: 100, height: 20))
        XCTAssertEqual(positionings[1].frame, CGRect(x: 0, y: 60, width: 100, height: 20))
        XCTAssertEqual(positionings[2].frame, CGRect(x: 0, y: 80, width: 100, height: 20))
    }

    func testMixedAlignment() {
        let parameters = [
            Parameter(element: "A", height: 20, alignment: .top),
            Parameter(element: "B", height: 20, alignment: .flexibleSize),
            Parameter(element: "C", height: 20, alignment: .bottom),
        ]

        let positionings = Resolver().resolve(parameters: parameters, bounds: CGRect(x: 0, y: 0, width: 100, height: 100), offset: 0)
        XCTAssertEqual(positionings[0].frame, CGRect(x: 0, y: 0, width: 100, height: 20))
        XCTAssertEqual(positionings[1].frame, CGRect(x: 0, y: 20, width: 100, height: 60))
        XCTAssertEqual(positionings[2].frame, CGRect(x: 0, y: 80, width: 100, height: 20))
    }

    func testMixedCenteringAlignment() {
        let parameters = [
            Parameter(element: "A", height: 20, alignment: .top),
            Parameter(element: "B1", height: 20, alignment: .flexibleSize),
            Parameter(element: "B2", height: 0, alignment: .flexibleSize),
            Parameter(element: "C", height: 20, alignment: .bottom),
        ]

        let positionings = Resolver().resolve(parameters: parameters, bounds: CGRect(x: 0, y: 0, width: 100, height: 100), offset: 0)
        XCTAssertEqual(positionings[0].frame, CGRect(x: 0, y: 0, width: 100, height: 20))
        XCTAssertEqual(positionings[1].frame, CGRect(x: 0, y: 20, width: 100, height: 40))
        XCTAssertEqual(positionings[2].frame, CGRect(x: 0, y: 60, width: 100, height: 20))
        XCTAssertEqual(positionings[3].frame, CGRect(x: 0, y: 80, width: 100, height: 20))
    }
}
