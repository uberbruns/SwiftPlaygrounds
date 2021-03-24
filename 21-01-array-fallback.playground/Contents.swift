import Cocoa

extension RandomAccessCollection {
    public subscript(_ index: Index, default defaultElement: @autoclosure () -> Element) -> Element {
        guard indices.contains(index) else {
            return defaultElement()
        }
        return self[index]
    }

    public subscript(_ index: Index, default defaultElement: @autoclosure () -> Element?) -> Element? {
        guard indices.contains(index) else {
            return defaultElement()
        }
        return self[index]
    }
}



let abc = ["a", "b", "c"]

print(abc[1, default: "x"])
print(abc[4, default: "x"])

print(abc[1, default: nil] ?? "nil")
print(abc[4, default: nil] ?? "nil")

let foo = ["a": 1]

print(foo["b", default: 0])
