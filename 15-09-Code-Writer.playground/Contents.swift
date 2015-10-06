//: Playground - noun: a place where people can play

import UIKit

struct Code {
    
    typealias CodeBlock = () -> ()
    
    private var indentionLevel = 0
    private var codeData = ""
    private var tabs = "    "
    
    var code: String {
        return codeData
    }
    
    init() {}
    
    
    mutating func add(code: String) {
        addNewLine()
        addIndention()
        codeData += code
    }
    
    mutating func add(codeBlock: CodeBlock) {
        indentionLevel++
        addIndention()
        codeBlock()
        indentionLevel--
    }
    
    
    mutating func addString(code: String) {
        codeData += code
    }
    
    
    mutating func addIndention() {
        codeData += Array(count: indentionLevel, repeatedValue: tabs).joinWithSeparator("")
    }
    
    mutating func addNewLine() {
        codeData += "\n"
    }
    
    
}


var code = Code()

code.add("if a == b {")
code.add {
    code.add("if a == 9 {")
    code.add {
    code.add("return flase")
    }
    code.add("}")
    code.add("return true")
}
code.add("}")

print(code.code)
