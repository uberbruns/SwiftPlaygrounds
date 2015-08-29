//: Playground - noun: a place where people can play

import UIKit

var a = 3
var b = 2*2*2*2*2*2*2

String(a, radix: 2, uppercase: false)
String(b, radix: 2, uppercase: false)

func twoIntHash(a:Int, _ b:Int) -> UInt64
{
    // Prepare Input
    let a64 = UInt64(abs(a) % Int(UInt32.max))
    String(a64, radix: 2, uppercase: false)
    
    let b64 = UInt64(abs(b) % Int(UInt32.max))
    String(b64, radix: 2, uppercase: false)

    // Hash
    var hash: UInt64 = 0
    String(hash, radix: 2, uppercase: false)

    hash = a64 << 32
    String(hash, radix: 2, uppercase: false)

    hash |= b64
    String(hash, radix: 2, uppercase: false)
    
    return hash
}

let result = twoIntHash(a, b)
String(result, radix: 2, uppercase: false)
