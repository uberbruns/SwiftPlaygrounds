//
//  SingleSelectionListTests.swift
//  SingleSelectionListTests
//
//  Created by Karsten Bruns on 10.03.21.
//

import XCTest
@testable import UBRSingleSelectionList

class SingleSelectionListTests: XCTestCase {

    func test_basics() throws {
        let lists = [
            SingleSelectionList(head: ["a", "b", "c"], selected: "d", tail: ["e", "f", "g"]),
            SingleSelectionList(selected: "a", tail: ["b", "c", "d", "e", "f", "g"]),
            SingleSelectionList(head: ["a", "b", "c", "d", "e", "f"], selected: "g")
        ]

        for list in lists {
            XCTAssertEqual(Array(list.indices), [0, 1, 2, 3, 4, 5, 6])
            XCTAssertEqual(list.map({ $0 }), ["a", "b", "c", "d", "e", "f", "g"])
            XCTAssertEqual(list.first, "a")
            XCTAssertEqual(list.last, "g")
        }
    }

    func test_singleElement() throws {
        let list = SingleSelectionList(selected: "a")
        XCTAssertEqual(Array(list.indices), [0])
        XCTAssertEqual(list.map({ $0 }), ["a"])
        XCTAssertEqual(list.first, "a")
        XCTAssertEqual(list.last, "a")
        XCTAssertEqual(list.selectedIndex, 0)
        XCTAssertEqual(list.selected, "a")
    }

    func test_selection() throws {
        let list = SingleSelectionList(head: ["a", "b", "c"], selected: "d", tail: ["e", "f", "g"])
        XCTAssertEqual(list.selectedIndex, 3)
        XCTAssertEqual(list.selected, "d")
    }

    func test_changeSelection() throws {
        let aToG = ["a", "b", "c", "d", "e", "f", "g"]
        let lists = [
            (SingleSelectionList(selected: "a"), ["a"]),
            (SingleSelectionList(head: ["a"], selected: "b", tail: ["c"]), ["a", "b", "c"]),
            (SingleSelectionList(head: ["a", "b", "c"], selected: "d", tail: ["e", "f", "g"]), aToG),
            (SingleSelectionList(selected: "a", tail: ["b", "c", "d", "e", "f", "g"]), aToG),
            (SingleSelectionList(head: ["a", "b", "c", "d", "e", "f"], selected: "g"), aToG)
        ]

        for (list, expectedSequence) in lists {
            for (index, element) in list.enumerated() {
                let list = list.selecting(element: element)
                XCTAssertEqual(list.selectedIndex, index)
                XCTAssertEqual(list.selected, element)
                XCTAssertEqual(Array(list.indices), Array(expectedSequence.indices))
                XCTAssertEqual(list.map({ $0 }), expectedSequence)
            }
        }
    }
}
