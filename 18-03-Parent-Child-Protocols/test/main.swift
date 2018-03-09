//
//  main.swift
//  test
//
//  Created by Karsten Bruns on 02.03.18.
//  Copyright © 2018 bruns.me. All rights reserved.
//

import Foundation

class Foo {
    var title: String = "" {
        didSet {
            print(title)
        }
    }
}


// MARK: - Child

protocol Child: class { }


protocol MyChild: Child {
    init(parent: MyParent)
    func printSomething()
}


class MyChildImpl: Foo, MyChild {

    private weak var parent: MyParent?
    
    required init(parent: MyParent) {
        self.parent = parent
    }
    
    func printSomething() {
        print(#function)
    }
}


// MARK: - Parent

protocol Parent: class {
    var foo: Foo { get }
}


protocol MyParent: Parent { }


class MyParentImpl<C>: MyParent where C: MyChild & Foo {
    
    private(set) lazy var child = C.self(parent: self)
    
    var foo: Foo {
        return child
    }

    init() {
        child.printSomething()
    }
}


let parent = MyParentImpl<MyChildImpl>()
let foo = parent.foo
foo.title = "Hello"
