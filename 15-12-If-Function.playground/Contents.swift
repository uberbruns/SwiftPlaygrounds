import Foundation

let x = 0
let y = 0
var r: Int?


// Idea A: If function

func iff<T>(cond: Bool, _ a: T) -> T? {
    if cond {
        return a
    } else {
        return nil
    }
}


func iff<T>(cond: Bool, _ a: T, _ b: T) -> T {
    if cond {
        return a
    } else {
        return b
    }
}


r = x == y ? 42 : 23
r = x != y ? 42 : nil

r = iff(x == y, 42, 23) //-> 42
r = iff(x != y, 42, 23) //-> 23

r = iff(x == y, 42) //-> 41
r = iff(x != y, 42) //-> nil

r = iff(x == y, 42).map({ $0 / 2 }) //-> 21
r = iff(x != y, 42).map({ $0 / 2 }) //-> nil



// Idea B: Extend Bool

extension Bool {
    
    func map<T>(a: T, _ b: T) -> T {
        if self {
            return a
        } else {
            return b
        }
    }
    
    func map<T>(a: T) -> T? {
        if self {
            return a
        } else {
            return nil
        }
    }

}


r = x == y ? 42 : 23
r = x != y ? 42 : nil


r = (x == y).map(42, 23) //-> 42
r = (x != y).map(42, 23) //-> 23

r = (x == y).map(42) //-> 42
r = (x != y).map(42) //-> nil

r = (x == y).map(42) //-> 42
r = (x != y).map(42) ?? 23 //-> 23


// r = x == y -> 42 ?? 23
// r = 42 ?? 23 if x == y
//
// r ??= 5
