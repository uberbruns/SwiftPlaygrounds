//: Playground - noun: a place where people can play

import UIKit

// Protocol types in arrays

protocol BaseProtocol {
    func baseFunc()
}


protocol ExtendedProtocol : BaseProtocol {
    func extendedFunc()
}

struct ExtendedFoo : ExtendedProtocol {
    func baseFunc() { print("Works!") }
    func extendedFunc() {}
}


func bar(foo: [BaseProtocol]) {
    foo.first?.baseFunc()
}

let a = ExtendedFoo()
let b: [ExtendedFoo] = [a]
let c: [BaseProtocol] = b.map({ $0 })


bar([a])
bar(c)

// bar(b)
// error: cannot convert value of type '[ExtendedFoo]' to expected argument type '[BaseProtocol]'



// Protocols and Generics

let d: BaseProtocol = a

struct GenericType<T : BaseProtocol> {
    
    let foo: T
    
    init(foo: T) {
        self.foo = foo
    }
    
}


let g1 = GenericType(foo: a) // Works

// let g2 = GenericType(foo: d)
//  error: cannot invoke initializer for type 'GenericType<T>' with an argument list of type '(foo: BaseProtocol)'




