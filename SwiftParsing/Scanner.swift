// Playground - noun: a place where people can play

import Foundation

class Scanner {
    let string:String
    var location:String.Index
    var skippedCharacters:CharacterSet?

    init(string:String) {
        self.string = string
        location = string.startIndex
        skippedCharacters = whiteSpaceCharacterSet
    }

    var atEnd:Bool {
        get {
            return location == string.endIndex
        }
    }

    func try(@noescape closure:Void -> Bool) -> Bool {
        let savedLocation = location
        let result = closure()
        if result == false {
            location = savedLocation
        }
        return result
    }

    func try<T> (@noescape closure:Void -> T?) -> T? {
        let savedLocation = location
        let result = closure()
        if result == nil {
            location = savedLocation
        }
        return result
    }

    func suppressSkip(@noescape closure:Void -> Void) {
        let savedSkippedCharacters = skippedCharacters
        skippedCharacters = nil
        closure()
        skippedCharacters = savedSkippedCharacters
    }

    func next() -> Character? {
        if location >= string.endIndex {
            return nil
        }
        let value = string[location]
        location = advance(location, 1)
        return value
    }

    func back() {
        assert(location != string.startIndex)
        location = advance(location, -1)
    }

    func skip() {
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

    func scanString(string:String) -> Bool {
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

    func scanCharacter(character:Character) -> Bool {
        return try () {
            skip()
            if character == next() {
                return true
            }
        return false
        }
    }

    func scanCharacterFromSet(characterSet:CharacterSet) -> Character? {
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

    func scanCharactersFromSet(characterSet:CharacterSet) -> String? {
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

    func scanDouble() -> Double? {
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
}

extension Scanner: Printable {
    var description: String {
        get {
            let prefix = string.substringToIndex(location)
            let suffix = string.substringFromIndex(location)
            return "[\(prefix)] <|> [\(suffix)]"
        }
    }
}

extension Scanner {
    func scanCGFloat() -> CGFloat? {
        if let double = scanDouble() {
            return CGFloat(double)
        }
        else {
            return nil
        }
    }
}
