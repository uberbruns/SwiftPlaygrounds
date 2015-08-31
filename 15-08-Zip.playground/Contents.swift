//: Playground - noun: a place where people can play

import UIKit

var a = [1,2,3,4,5]
var b = [1,2,3,4,5]



let f1 = a.count == b.count ? (zip(a, b).filter({ $0.0 != $0.1 }).count == 0) : false
let f2 = a.count == b.count ? Array(zip(a, b)).indexOf{ $0.0 != $0.1 } == nil : false


print(f1)
print(f2)
