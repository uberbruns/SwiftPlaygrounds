//: Playground - noun: a place where people can play

import UIKit


struct NamedValue : Equatable {

    let name: String
    let value: Any
    private let valueHash: Int
    

    init<T: Hashable>(name: String, value: T)
    {
        self.value = value
        self.valueHash = value.hashValue
        self.name = name
    }
    
}


func ==(lhs: NamedValue, rhs: NamedValue) -> Bool
{
    return lhs.valueHash == rhs.valueHash
}


struct NonGenericTarget {

    var namedValues: [NamedValue] = []

}


extension NonGenericTarget : Equatable {

}


func ==(lhs: NonGenericTarget, rhs: NonGenericTarget) -> Bool
{
    return lhs.namedValues == rhs.namedValues
}


let v = NamedValue(name: "Hello", value: ["World", 123])
var c = NonGenericTarget()
c.namedValues = [v]





//enum NamedValueB : Equatable {
//    case V(name: String, value: Hashable)
//}
//
//
//func ==(lhs: NamedValueB, rhs: NamedValueB) -> Bool
//{
//    switch lhs {
//    case .V(let lhsName, let lhsValue) :
//        switch rhs {
//        case .V(let rhsName, let rhsValue) :
//            return lhsName == rhsName && lhsValue.hashValue == rhsValue.hashValue
//        }
//    }
//}
//
//
//let a = NamedValueB.V(name: "Hello", value: 123)
//let b = NamedValueB.V(name: "Hello", value: 123)
//
//let bool = a == b




