// Playground - noun: a place where people can play

import Foundation
import SwiftUtilities

public class Scanner: GeneratorType {
    public typealias Element = Character
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

    public func back() throws {
        guard location != string.startIndex else {
            throw SwiftUtilities.Error.Generic("Underflow")
        }
        location = location.advancedBy(-1)
    }

    public func skip() {
        if atEnd {
            return
        }
        guard let skippedCharacters = skippedCharacters else {
            return
        }
        for C in self {
            if skippedCharacters.contains(C) == false {
                try! back()
                break
            }
        }
    }

    public func scanString(string:String) -> Bool {
        assert(string.isEmpty == false)

        return with() {
            skip()
            var searchStringGenerator = string.characters.generate()
            while true {
                let searchStringGeneratorValue = searchStringGenerator.next()
                if searchStringGeneratorValue == nil {
                    return true
                }
                let stringGeneratorValue = next()
                if stringGeneratorValue == nil {
                    break
                }
                if searchStringGeneratorValue != stringGeneratorValue {
                    break
                }
            }
            return false
        }
    }

    public func scanCharacter(character:Character) -> Bool {
        return with () {
            skip()
            return character == next()
        }
    }

    public func scanCharacterFromSet(characterSet:CharacterSet) -> Character? {
        return with() {
            skip()
            if let character = next() {
                if characterSet.contains(character) {
                    return character
                }
            }
            return nil
        }
    }

    public func scanCharactersFromSet(characterSet:CharacterSet) -> String? {
        return with() {
            skip()
            let start = location
            for C in self {
                if characterSet.contains(C) == false {
                    try! back()
                    break
                }
            }
            guard start.distanceTo(location) > 0 else {
                return nil
            }

            return string.substringWithRange(start..<location)
        }
    }

    public func scanDouble() -> Double? {
        return with() {
            skip()
            guard let string = scanCharactersFromSet(CharacterSet(string: "0123456789Ee.-")) else {
                return nil
            }
            return try? Double.fromString(string)
        }
    }

//    public func scan <T:FloatingPointType> () -> T? {
//        guard let double = scanDouble() else {
//            return nil
//        }
//        return T(double)
//    }

    public func scan(expression: RegularExpression) -> String? {
        return with() {
            skip()
            if let match = expression.match(remaining) {
                let range = match.ranges[0]
                let offset = remaining.startIndex.distanceTo(range.endIndex)
                location = location.advancedBy(offset)
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
        let prefix = string.substringToIndex(location)
        let suffix = string.substringFromIndex(location)
        return "[\(prefix)] <|> [\(suffix)]"
    }
}

extension Scanner: SequenceType {
    public typealias Generator = Scanner
    public func generate() -> Generator {
        return self
    }
}

public extension Scanner {
    func scanCGFloat() -> CGFloat? {
        guard let double = scanDouble() else {
            return nil
        }
        return CGFloat(double)
    }
}
