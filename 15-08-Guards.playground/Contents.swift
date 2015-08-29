//: Playground - noun: a place where people can play

import UIKit

var string: String? = "Hello, playground!"


// Function
func say(string: String?) {
    guard let string = string else { return }
    print("Func:", string)
}
say(string)


// While
var foo = 0
while foo < 3 {
    guard let string = string else { break }
    print("While:", string)
    foo++
}


// Switch
enum Bar {
    case A(String?), B(Int?)
}
let bar = Bar.A(string)

switch bar {
case .A(let string) :
    guard let s = string else { break }
    print("Switch:", s)
case .B(let int) :
    guard let i = int else { break }
    print("Switch:", i)
}


// Do
hello: do {
    
    guard let string = string else { break hello }
    print("Do:", string)
    
    // For
    print("For: ", terminator: "")
    let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz!,".characters
    let secretAlphabet = "MNOPQRSTUVWXYZABCDEFGHIJKL mnopqrstuvwxyzabcdefghijkl?.".characters
    for letter in string.characters {
        guard let index = alphabet.indexOf(letter) else { continue }
        print(secretAlphabet[index], terminator: "")
    }
}

