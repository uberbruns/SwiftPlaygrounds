//: Playground - noun: a place where people can play

import UIKit

func stringHash(str1 str1: String, str2: String) -> Int {
    return (31 &* str1.hashValue) &+ str2.hashValue
}

stringHash(str1: "aa", str2: "b")
stringHash(str1: "aa", str2: "c")


let a: Int8 = 120
a &+ 8
