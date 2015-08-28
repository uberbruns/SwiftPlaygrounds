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
bar([a])

let b: [ExtendedFoo] = [a]
// bar(b)
// error: cannot convert value of type '[ExtendedFoo]' to expected argument type '[BaseProtocol]'

let c: [BaseProtocol] = b.map({ $0 })
bar(c)



// Protocols and Generics


struct GenericType<T : BaseProtocol> {
    
    let foo: T
    
    init(foo: T) {
        self.foo = foo
    }
    
}

let g1 = GenericType(foo: a) // Works

let d: BaseProtocol = a
// let g2 = GenericType(foo: d)
// error: cannot invoke initializer for type 'GenericType<T>' with an argument list of type '(foo: BaseProtocol)'
// note: expected an argument list of type '(foo: T)'




