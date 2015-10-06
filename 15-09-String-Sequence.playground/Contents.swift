//: Playground - noun: a place where people can play

import UIKit

let inputA = ["main","device","channel"]
let inputB = ["device","channel", "Configuration", "Groups"]

if let index = inputA.indexOf({ $0.lowercaseString == inputB[0].lowercaseString }) {
    print(inputA[0..<index] + inputB)
}

