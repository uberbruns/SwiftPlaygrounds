import UIKit

protocol BoxProtocol {
    var content: [ContentProtocol] { get }
}


protocol ContentProtocol { }


protocol MyContentProtocol : ContentProtocol { }


struct MyBox : BoxProtocol {
    var content: [ContentProtocol] { return myContent.map { $0 as ContentProtocol }}
    let myContent: [MyContentProtocol]
}

struct MyContentA : MyContentProtocol { }
struct MyContentB : MyContentProtocol { }

let a = MyBox(myContent: [MyContentA()])
let b = MyBox(myContent: [MyContentB()])



struct Doreen {
    private let birthday: NSDate
    var age: Int {
        let now = NSDate()
        let ageComponents = NSCalendar.currentCalendar().components(.Year, fromDate: birthday, toDate: now, options: [])
        return min(29, ageComponents.year)
    }
    
    func say() {
        print("Läuft")
    }
}





 
/*

protocol BoxProtocol {
    associatedtype C = ContentProtocol
    var content: C { get }
}


protocol ContentProtocol { }


protocol MyContentProtocol : ContentProtocol { }

struct MyContentType : ContentProtocol { }


struct MyBox : BoxProtocol {
    typealias C = MyContentA
    var content: MyContentA
}



class Foo<B: BoxProtocol where B.C: ContentProtocol> {
}



struct MyContentA : MyContentProtocol { }
struct MyContentB : MyContentProtocol { }

let a = MyBox(content: MyContentA())
let foo = Foo<MyBox>()
 
 */


/*


struct Test {
    static let computedLet: Int = {
        print("static computedLet")
        return 5
    }()
    
    let computedLet: Int = {
        print("computedLet")
        return 5
    }()
    
    var computedVar: Int {
        print("computedVar")
        return 5
    }

    var computedVarWithFunc: Int = {
        print("computedVarWithFunc")
        return 5
    }()
    
    lazy var lazyComputedVarWithFunc: Int = {
        print("lazyComputedVarWithFunc")
        return 5
    }()

    var foo: Int
    
    init(foo: Int) {
        self.foo = foo
    }
}

Test.computedLet
Test.computedLet
Test.computedLet
Test.computedLet


let test = Test(foo: 5)
test.computedLet
test.computedLet
test.computedLet
test.computedLet


test.computedVar
test.computedVar
test.computedVar
test.computedVar

var test2 = Test(foo: 5)
test2.computedVar
test2.computedVar
test2.computedVar
test2.computedVar

test2.computedVarWithFunc
test2.computedVarWithFunc
test2.computedVarWithFunc
test2.computedVarWithFunc
test2.computedVarWithFunc

test2.lazyComputedVarWithFunc
test2.lazyComputedVarWithFunc
test2.lazyComputedVarWithFunc
test2.lazyComputedVarWithFunc
test2.lazyComputedVarWithFunc


*/

struct ABC {
    static let foo = 1
    let bar = 2
}


let mirror = Mirror(reflecting: ABC.self)
print(mirror)


enum Weekday: Int {
    case Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday
    static let allValues = [Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday]
}


let input: Set<Weekday> = [.Monday, .Tuesday]

switch input {
case [.Monday, .Tuesday] :
    print("...")
default :
    break
}


var test: Int? = 5

extension Optional {
    var exists: Bool {
        return self != nil
    }
}

test.exists



