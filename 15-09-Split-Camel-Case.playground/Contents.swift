//: Playground - noun: a place where people can play

import UIKit

let str = "deviceJSONChannel/ConfigurationGroup3_Type-object"
let lowerCaseLetters = "abcdefghijklmnopqrstuvwxyz0123456789"
let upperCaseLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

var components: [String] = [""]
for (index, character) in str.characters.enumerate() {
    
    let lastComponentIsEmpty = components.last!.characters.count == 0
    let isUppercase = upperCaseLetters.characters.contains(character)
    let isLowercase = lowerCaseLetters.characters.contains(character)

    if isUppercase {
        
        var nextIsLowerCase = false
        var lastWasLowerCase = false

        if index > 0 {
            let prevCharacter = str.substringWithRange(Range(start: str.startIndex.advancedBy(index-1), end: str.startIndex.advancedBy(index)))
            lastWasLowerCase = lowerCaseLetters.containsString(prevCharacter)
        }

        if index < str.characters.count-1 {
            let nextCharacter = str.substringWithRange(Range(start: str.startIndex.advancedBy(index+1), end: str.startIndex.advancedBy(index+2)))
            nextIsLowerCase = lowerCaseLetters.containsString(nextCharacter)
        }
        
        if (nextIsLowerCase || lastWasLowerCase) && !lastComponentIsEmpty {
            components.append("")
        }
        
    }
    
    if !isUppercase && !isLowercase && !lastComponentIsEmpty {
        components.append("")
    }
    
    if isUppercase || isLowercase {
        var newCharacter =  String(character)
        if lastComponentIsEmpty {
            newCharacter = newCharacter.uppercaseString
        }
        components[components.count-1] = components.last! + newCharacter
    }
    
}

print(components)



