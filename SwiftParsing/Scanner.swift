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
        return location == string.endIndex
    }

    public var remaining:String {
        return string[location..<string.endIndex]
    }

    public func with(@noescape closure:Void -> Bool) -> Bool {
        let savedLocation = location
        let result = closure()
        if result == false {
            location = savedLocation
        }
        return result
    }

    public func with<T> (@noescape closure:Void -> T?) -> T? {
        let savedLocation = location
        let result = closure()
        if result == nil {
            location = savedLocation
        }
        return result
    }

    public func suppressSkip <T>(@noescape closure:Void -> T) -> T {
        let savedSkippedCharacters = skippedCharacters
        skippedCharacters = nil
        let result = closure()
        skippedCharacters = savedSkippedCharacters
        return result
    }

    public func next() -> Character? {
        if location >= string.endIndex {
            return nil
        }
        let value = string[location]
        location = location.advancedBy(1)
        return value
    }

    public func back() {
        assert(location != string.startIndex)
        location = location.advancedBy(-1)
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

        let result = with() {
            skip()
            var searchStringGenerator = string.characters.generate()
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
        return with () {
            skip()
            return character == next()
        }
    }

    public func scanCharacterFromSet(characterSet:CharacterSet) -> Character? {
        let result:Character? = with() {
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
        let result:String? = with() {
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
            if start.distanceTo(location) == 0 {
                return nil
            }
            else {
                return string.substringWithRange(start..<location)
            }
        }
        return result
    }

    public func scanDouble() -> Double? {
        let result:Double? = with() {
            skip()
            if let string = scanCharactersFromSet(CharacterSet(string: "0123456789Ee.-")) {
                return try? Double.fromString(string)
            }
            else {
                return nil
            }
        }
        return result
    }

    public func scan(expression:RegularExpression) -> String? {
        return with() {
            skip()
            if let match = expression.match(remaining) {
                let range = match.ranges[0]
                location = range.endIndex
                return match.strings[0]
            }
            return nil
        }
    }


    public func scanRegularExpression(string:String) throws -> String? {
        let expression = try RegularExpression(string)
        return scan(expression)
    }


}

extension Scanner: CustomStringConvertible {
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
