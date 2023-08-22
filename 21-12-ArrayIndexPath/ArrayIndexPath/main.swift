//
//  main.swift
//  ArrayIndexPath
//
//  Created by Karsten Bruns on 13.06.21.
//

import Foundation


extension Array {
    subscript(indexPath indexPath: IndexPath, children childrenKeyPath: WritableKeyPath<Element, [Element]>) -> Element {
        get {
            if indexPath.count > 1 {
                var indexPath = indexPath
                let index = indexPath.removeFirst()
                return self[index][keyPath: childrenKeyPath][indexPath: indexPath, children: childrenKeyPath]
            } else if indexPath.count == 1 {
                let index = indexPath[0]
                return self[index]
            } else {
                fatalError()
            }
        }
        set {
            if indexPath.count > 1 {
                var indexPath = indexPath
                let index = indexPath.removeFirst()
                self[index][keyPath: childrenKeyPath][indexPath: indexPath, children: childrenKeyPath] = newValue
            } else if indexPath.count == 1 {
                let index = indexPath[0]
                self[index] = newValue
            } else {
                fatalError()
            }
        }
    }
}




struct Item {
    var title: String
    var children: [Item]
}


var nestedItems = [
    Item(
        title: "Foo",
        children: [
            Item(
                title: "Bar 1",
                children: []
            ),
            Item(
                title: "Bar 2",
                children: [
                    Item(
                        title: "XXX 1",
                        children: []
                    ),
                    Item(
                        title: "XXX 2",
                        children: []
                    ),
                    Item(
                        title: "XXX 3",
                        children: []
                    )
                ]
            ),
            Item(
                title: "Bar 3",
                children: []
            )
        ]
    )
]

let indexPath = IndexPath(index: 0).appending(1).appending(2)
print(nestedItems[indexPath: indexPath, children: \.children])
nestedItems[indexPath: indexPath, children: \.children].title = "XXX 9"
print(nestedItems[indexPath: indexPath, children: \.children])
