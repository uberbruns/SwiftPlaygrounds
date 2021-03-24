import Foundation


public struct SingleSelectionList<Element> {
    private var currentIndex = 0

    private let head: [Element]

    public let selected: Element

    private let tail: [Element]

    public let count: Int

    public init(head: [Element] = [], selected: Element, tail: [Element] = []) {
        self.head = head
        self.selected = selected
        self.tail = tail
        self.count = head.count + 1 + tail.count
    }

    public var first: Element {
        head.first ?? selected
    }

    public var last: Element {
        tail.last ?? selected
    }

    public var selectedIndex: Int {
        head.count
    }
}


extension SingleSelectionList: Sequence, IteratorProtocol {
    mutating public func next() -> Element? {
        defer {
            currentIndex += 1
        }
        if self.indices.contains(currentIndex) {
            return self[currentIndex]
        } else {
            return nil
        }
    }
}


extension SingleSelectionList: Collection {
    public typealias Element = Element
    public typealias Index = Int

    public var startIndex: Index {
        return 0
    }

    public var endIndex: Index {
        return count
    }

    public subscript (position: Index) -> Element {
        if head.indices.contains(position) {
            return head[position]
        } else if position == head.count {
            return selected
        } else {
            let tailIndex = position - head.count - 1
            if tail.indices.contains(tailIndex) {
                return tail[tailIndex]
            } else {
                preconditionFailure("Out of bounds")
            }
        }
    }

    public func index(after i: Index) -> Index {
        return i + 1
    }
}

extension SingleSelectionList: BidirectionalCollection {
    public func index(before i: Index) -> Index {
        return i - 1
    }
}


public extension SingleSelectionList {
    init(_ firstElement: Element) {
        self.init(firstElement, rest: [])
    }

    init(_ firstElement: Element, rest: Element...) {
        self.init(firstElement, rest: rest)
    }

    init(_ firstElement: Element, rest: [Element]) {
        self.init(selected: firstElement, tail: rest)
    }
}


public extension SingleSelectionList where Element: Equatable {
    func selecting(element: Element) -> SingleSelectionList {
        if element == selected {
            return self
        }

        if let headIndex = head.firstIndex(of: element) {
            let newHead = Array(head[..<headIndex])
            let newSelected = element
            let tailElementsIndex = head.index(after: headIndex)
            let newTail: [Element]
            if head.indices.contains(tailElementsIndex) {
                let newTailElements = Array(head[tailElementsIndex...])
                newTail = newTailElements + [selected] + tail
            } else {
                newTail = [selected] + tail
            }

            return SingleSelectionList(
                head: newHead,
                selected: newSelected,
                tail: newTail
            )
        } else if let tailIndex = tail.firstIndex(of: element) {
            let newHead: [Element]
            let newSelected = element
            let newTail: [Element]
            let newTailIndex = tail.index(after: tailIndex)
            if tail.indices.contains(newTailIndex) {
                newTail = Array(tail[newTailIndex...])
            } else {
                newTail = []
            }
            let headElementsIndex = tail.index(before: tailIndex)
            if tail.indices.contains(headElementsIndex) {
                let newHeadElements = Array(tail[...headElementsIndex])
                newHead = head + [selected] + newHeadElements
            } else {
                newHead = head + [selected]
            }

            return SingleSelectionList(
                head: newHead,
                selected: newSelected,
                tail: newTail
            )
        }

        preconditionFailure("Element not part of list.")
    }
}

