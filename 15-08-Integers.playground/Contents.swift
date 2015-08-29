//: Playground - noun: a place where people can play

import UIKit

var a = "Hello World".hash
var b = "Moin".hash

String(a, radix: 2, uppercase: false)


func twoIntHash(a:Int, _ b:Int) -> UInt64
{
    let a64 = UInt64(abs(a) % Int(UInt32.max))
    let b64 = UInt64(abs(b) % Int(UInt32.max))
    return a64 << 32 | b64
}

twoIntHash(a, b)

