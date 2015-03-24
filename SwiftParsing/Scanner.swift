// Playground - noun: a place where people can play

import Foundation
import SwiftUtilities

public class Scanner {
    public let string:String
    public var location:String.Index
    public var skippedCharacters:CharacterSet?

    public init(string:String) {
        self.string = string
        location = string.startIndex
        skippedCharacters = whiteSpaceCharacterSet
    }

    public var atEnd:Bool {
        get {
            return location == string.endIndex
        }
    }

    public var remaining:String {
        get {
            return string[location..<string.endIndex]
        }
    }


    public func try(@noescape closure:Void -> Bool) -> Bool {
        let savedLocation = location
        let result = closure()
        if result == false {
            location = savedLocation
        }
        return result
    }

    public func try<T> (@noescape closure:Void -> T?) -> T? {
        let savedLocation = location
        let result = closure()
        if result == nil {
            location = savedLocation
        }
        return result
    }

    public func suppressSkip(@noescape closure:Void -> Void) {
        let savedSkippedCharacters = skippedCharacters
        skippedCharacters = nil
        closure()
        skippedCharacters = savedSkippedCharacters
    }

    public func next() -> Character? {
        if location >= string.endIndex {
            return nil
        }
        let value = string[location]
        location = advance(location, 1)
        return value
    }

    public func back() {
        assert(location != string.startIndex)
        location = advance(location, -1)
    }

    public func skip() {
        if let skippedCharacters = skippedCharacters {
            while true {
                if let C = next() {
                    if skippedCharacters.contains(C) == false {
                        back()
                        break
                    }
                }
                else {
                    break
                }
            }
        }
    }

    public func scanString(string:String) -> Bool {
        assert(string != "")
        let result = try() {
            skip()
            var searchStringGenerator = string.generate()
            while true {
                let searchStringGeneratorValue = searchStringGenerator.next()
                if searchStringGeneratorValue == nil {
                    return true
                }
                let stringGeneratorValue = next()
                if stringGeneratorValue == nil {
                    return false
                }
                if searchStringGeneratorValue != stringGeneratorValue {
                    return false
                }
            }
        }
        return result
    }

    public func scanCharacter(character:Character) -> Bool {
        return try () {
            skip()
            if character == next() {
                return true
            }
        return false
        }
    }

    public func scanCharacterFromSet(characterSet:CharacterSet) -> Character? {
        let result:Character? = try() {
            skip()
            if let character = next() {
                if characterSet.contains(character) {
                    return character
                }
            }
            return nil
        }
        return result
    }

    public func scanCharactersFromSet(characterSet:CharacterSet) -> String? {
        let result:String? = try() {
            skip()
            let start = location
            while true {
                if let C = next() {
                    if characterSet.contains(C) == false {
                        back()
                        break
                    }
                }
                else {
                    break
                }
            }
            if distance(start, location) == 0 {
                return nil
            }
            else {
                return string.substringWithRange(start..<location)
            }
        }
        return result
    }

    public func scanDouble() -> Double? {
        let result:Double? = try() {
            skip()
            let start = location
            if let string = scanCharactersFromSet(CharacterSet(string: "0123456789Ee.-")) {
                return Double.fromString(string)
            }
            else {
                return nil
            }
        }
        return result
    }

    public func scanRegularExpression(string:String) -> String? {
        let result:String? = try() {
            skip()

            let expression = RegularExpression(string)
            let match = expression.match(remaining)

            let result = match?.groups[0].string
            location = location.advanc

            return nil
        }
        return result
    }


}

extension Scanner: Printable {
    public var description: String {
        get {
            let prefix = string.substringToIndex(location)
            let suffix = string.substringFromIndex(location)
            return "[\(prefix)] <|> [\(suffix)]"
        }
    }
}

public extension Scanner {
    func scanCGFloat() -> CGFloat? {
        if let double = scanDouble() {
            return CGFloat(double)
        }
        else {
            return nil
        }
    }
}
