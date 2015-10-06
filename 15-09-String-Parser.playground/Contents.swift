//: Playground - noun: a place where people can play

import UIKit

extension String {
    
    func extractWithRegEx(searchPattern searchPattern: String, index: Int = 0, options: NSRegularExpressionOptions = NSRegularExpressionOptions(rawValue: 0)) -> String? {
        
        guard let rx = try? NSRegularExpression(pattern: searchPattern, options: options) else { return nil }
        let range = NSMakeRange(0, self.characters.count)
        let matches = rx.matchesInString(self, options: NSMatchingOptions(rawValue: 0), range: range)
        
        if let match = matches.first where index < match.numberOfRanges {
            let matchRange = match.rangeAtIndex(index)
            let startIndex = self.startIndex.advancedBy(matchRange.location)
            let endIndex = startIndex.advancedBy(matchRange.length)
            return self.substringWithRange(Range(start: startIndex, end: endIndex))
        }
        
        return nil
    }
    
    
    func replaceWithRegEx(searchPattern searchPattern: String, replacePattern: String) -> String {
        
        guard let rx = try? NSRegularExpression(pattern: searchPattern, options: NSRegularExpressionOptions(rawValue: 0)) else { return self }
        let range = NSMakeRange(0, self.characters.count)
        let replacedText = rx.stringByReplacingMatchesInString(self, options: NSMatchingOptions(rawValue: 0), range: range, withTemplate: replacePattern)
        return replacedText
        
    }
    
}


func jsonify(var string: String) -> AnyObject? {
    
    string = string.stringByReplacingOccurrencesOfString("array<", withString: "[{")
    string = string.stringByReplacingOccurrencesOfString(">", withString: "\"}]")

    string = string.stringByAppendingString("\"")
    string = "{" + string + "}"
    
    string = string.stringByReplacingOccurrencesOfString("{", withString: "{\"")
    string = string.stringByReplacingOccurrencesOfString(", ", withString: "\", \"")
    string = string.stringByReplacingOccurrencesOfString(": ", withString: "\": \"")
    string = string.stringByReplacingOccurrencesOfString(" \"[", withString: " [")
    string = string.stringByReplacingOccurrencesOfString("]\"", withString: "]")
    string = string.stringByReplacingOccurrencesOfString("-object", withString: "")
    string = string.replaceWithRegEx(searchPattern: "\\[\\{\\\"([a-zA-Z0-9]*)\\\"\\}\\]", replacePattern: "\\[\\\"$1\\\"\\]")
        
    let data = string.dataUsingEncoding(NSUTF8StringEncoding)!
    
    do {
        return try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
    } catch let error {
        print("jsonified String:", string)
        print("")
        print(error)
    }
    
    return nil
}

do {
    let input = "getDeviceFunctionTypes() result: {inputDeviceFunctionTypes: array<inputDeviceFunctionType-object>, outputDeviceFunctionTypes: array<outputDeviceFunctionType-object>}"
    let resultInput = input.extractWithRegEx(searchPattern: "result: \\{(.+)\\}", index: 1)
}


do {
    let input = "getDeviceParameterTypesFromDeviceChannelConfigurationGroupType() result: {deviceParameterTypes: array<deviceParameterType-object>}"
    let resultInput = input.extractWithRegEx(searchPattern: "result: \\{(.+)\\}", index: 1)
}

do {
    let input = "getDeviceParameterTypesFromChannelType() result: {deviceParameterTypes: array<deviceParameterType-object>}"
    let resultInput = input.extractWithRegEx(searchPattern: "result: \\{(.+)\\}", index: 1)
}

do {
    let input = "getDigestAuthentificationInfos() result: {realm: string, domain: string, uri: string, nonce: string, opaque: string, algorithm: string, qop: string}"
    let resultInput = input.extractWithRegEx(searchPattern: "result: \\{(.+)\\}", index: 1)
}