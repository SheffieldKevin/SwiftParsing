//
//  Parser.swift
//  SwiftSVGTestNT
//
//  Created by Jonathan Wight on 3/14/15.
//  Copyright (c) 2015 No. All rights reserved.
//

import Foundation

struct Error {
    let string:String
    init(_ string:String) {
        self.string = string
        println("ERROR: \(string)")
    }
}

enum ParseResult {
  case Err(Error)
  case None
  case Ok(Any)
}

// Value, NonValue, Fail, CriticalError
// Success, Fail, Error

extension ParseResult {
    var isOK: Bool {
        get {
            switch self {
                case .Err:
                    return false
                case .Ok:
                    return true
                case .None:
                    return false
            }
        }
    }
    var value: Any? {
        get {
            switch self {
                case .Ok(let value):
                    return value
                default:
                    return nil
            }
        }
    }
}

extension ParseResult: Printable {
    var description: String {
        get {
            switch self {
                case .Err(let value):
                    return "ERROR: \(value)"
                case .Ok(let value):
                    return "VAL: \(value)"
                case .None:
                    return "NONE"
            }
        }
    }
}

// MARK: Protocols

protocol ContainerElement {
    var subelements:[Element] { get }
}

// MARK: Element

class Element {
    init() {
    }

    var strip:Bool = false
    var flatten:Bool = false
    var converter:(Any -> Any?)?

    final func parse(string:String) -> ParseResult {
        var scanner = Scanner(string: string)
        return parse(scanner)
    }

    func parse(scanner:Scanner) -> ParseResult {
        return .Err(Error("Fail"))
    }
}

extension Element {
    func makeStripped() -> Element {
        strip = true
        return self
    }

    func makeFlattened() -> Element {
        flatten = true
        return self
    }

    func makeConverted(converter:Any -> Any?) -> Element {
        self.converter = converter
        return self
    }

}

// MARK: Literal

class Literal: Element {
    let value:String

    init(_ value:String) {
        self.value = value
        super.init()
    }

    override func parse(scanner:Scanner) -> ParseResult {
        return scanner.scanString(value) ? .Ok(self.value) : .None
    }
}

extension Literal: Printable {
    var description:String {
        get {
            return "Literal(\"\(value)\")"
        }
    }
}


// MARK: Value

class Value: Element {
    let scan:((scanner:Scanner) -> Any?)

    init(scan:((scanner:Scanner) -> Any?)) {
        self.scan = scan
    }

    override func parse(scanner:Scanner) -> ParseResult {
        if let result = scan(scanner:scanner) {
            return .Ok(result)
        }
        else {
            return .None
        }
    }
}

extension Value: Printable {
    var description:String {
        get {
            return "DoubleValue()"
        }
    }
}

let cgFloatValue = Value() {
    (scanner:Scanner) -> Any? in
    return scanner.scanCGFloat()
}

let doubleValue = Value() {
    (scanner:Scanner) -> Any? in
    return scanner.scanDouble()
}

// MARK: Range


// TODO: rename
class RangeOf: Element {
    let min:Int?
    let max:Int?
    let subelement:Element

    init(min:Int?, max:Int?, subelement:Element) {
        self.min = min
        self.max = max
        self.subelement = subelement
        super.init()
    }

    override func parse(scanner:Scanner) -> ParseResult {
        var compoundResult:[Any] = []

        loop: while true {

            if let max = max where compoundResult.count == max {
                break loop
            }

            let result = subelement.parse(scanner)
            switch result {
                case .Ok(let value):
                    compoundResult.append(value)
                case .Err(let value):
                    return result
                case .None:
                    break loop
            }
        }

        if let min = min where compoundResult.count < min {
            return .Err(Error("Could not scan enough"))
        }

        if flatten {
            if compoundResult.count == 1 {
                return .Ok(compoundResult[0])
            }
            else if compoundResult.count == 0 {
                return .Ok(Void)
            }
            else {
                return .Err(Error("Could not flatten"))
            }
        }

        return .Ok(compoundResult)
    }
}

extension RangeOf: Printable {
    var description:String {
        get {
            return "RangeOf(\"\(subelement)\")"
        }
    }
}

extension RangeOf: ContainerElement {
    var subelements:[Element] {
        get {
            return [subelement]
        }
    }
}

func zeroOrOne(subelement:Element) -> RangeOf {
    let rangeOf = RangeOf(min:0, max:1, subelement:subelement)
    rangeOf.flatten = true
    return rangeOf
}

func oneOrMore(subelement:Element) -> RangeOf {
    let rangeOf = RangeOf(min:1, max:nil, subelement:subelement)
    return rangeOf
}

// MARK: OneOf

class OneOf: Element {
    let subelements:[Element]

    init(_ subelements:[Element]) {
        self.subelements = subelements
        super.init()
    }

    override func parse(scanner:Scanner) -> ParseResult {
        for element in subelements {
            let result = element.parse(scanner)
            if result.isOK {
                return result
            }
        }
        return .None
    }
}

extension OneOf: Printable {
    var description:String {
        get {
            let elementDescriptions = subelements.map() { return toString($0) }
            return "OneOf(\"\(elementDescriptions)\")"
        }
    }
}

extension OneOf: ContainerElement {
}

// MARK: Compound

class Compound: Element {
    let subelements:[Element]

    init(_ subelements:[Element]) {
        assert(subelements.count > 0)
        self.subelements = subelements
        super.init()
    }

    override func parse(scanner:Scanner) -> ParseResult {
        var compoundResult:[Any] = []
        loop: for element in subelements {
            if scanner.atEnd {
                break
            }
            let result = element.parse(scanner)
            switch result {
                case .Ok(let value):
                    if element.strip == false {
                        compoundResult.append(value)
                    }

                case .Err(let value):
                    return result
                case .None:
                    break loop
            }
        }

        var result:ParseResult = .None

        if compoundResult.count == 0 {
            result = .None
        }
        else if flatten == true {
            if compoundResult.count == 1 {
                result = .Ok(compoundResult[0])
            }
            else {
                result = .Err(Error("couldn't flatten"))
            }
        }
        else {
            result = .Ok(compoundResult)
        }

        if let converter = converter, let value = result.value {
            if let value = converter(value) {
                result = .Ok(value)
            }
            else {
                result = .Err(Error("Failed to convert"))
            }
        }

        return result
    }
}

extension Compound: Printable {
    var description:String {
        get {
            let elementDescriptions = subelements.map() { return toString($0) }
            return "Compound(\"\(elementDescriptions)\")"
        }
    }
}

extension Compound: ContainerElement {
}

// MARK: AtEnd

class AtEnd: Element {

    override func parse(scanner:Scanner) -> ParseResult {
        return scanner.atEnd ? .Ok(Void) : .Err(Error("Not at end"))
    }

}

let atEnd = AtEnd()

// MARK: Covenience operators

func | (lhs:Element, rhs:Element) -> OneOf {
    let result:OneOf
    if let lhs = lhs as? OneOf, let rhs = rhs as? OneOf {
        result = OneOf(lhs.subelements + rhs.subelements )
    }
    else if let lhs = lhs as? OneOf {
        result = OneOf(lhs.subelements + [rhs] )
    }
    else if let rhs = rhs as? OneOf {
        result = OneOf([lhs] + rhs.subelements )
    }
    else {
        result = OneOf([lhs, rhs] )
    }
    return result
}

func + (lhs:Element, rhs:Element) -> Compound {
    let result:Compound
    if let lhs = lhs as? Compound, let rhs = rhs as? Compound {
        result = Compound(lhs.subelements + rhs.subelements )
    }
    else if let lhs = lhs as? Compound {
        result = Compound(lhs.subelements + [rhs] )
    }
    else if let rhs = rhs as? Compound {
        result = Compound([lhs] + rhs.subelements )
    }
    else {
        result = Compound([lhs, rhs] )
    }
    return result
}