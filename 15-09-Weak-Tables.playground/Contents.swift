//: Playground - noun: a place where people can play

import UIKit

class HoldMe : NSObject {

}


let table = NSHashTable.weakObjectsHashTable()

var a: AnyObject? = HoldMe()

table.addObject(a)
print(table.count)

a = nil

for o in table.allObjects {
    print(o)
}

