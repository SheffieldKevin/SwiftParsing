//
//  Parser.swift
//  SwiftSVGTestNT
//
//  Created by Jonathan Wight on 3/14/15.
//  Copyright (c) 2015 No. All rights reserved.
//

import Foundation

public struct Error: ErrorType {
    public let string:String
    public init(_ string:String) {
        self.string = string
        print("ERROR: \(string)")
    }
}

public enum ParseResult {
  case None
  case Ok(Any)
}

// Value, NonValue, Fail, CriticalError
// Success, Fail, Error

public extension ParseResult {
    var isOK: Bool {
        get {
            switch self {
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

extension ParseResult: CustomStringConvertible {
    public var description: String {
        get {
            switch self {
                case .Ok(let value):
                    return "VAL: \(value)"
                case .None:
                    return "NONE"
            }
        }
    }
}

// MARK: Protocols

public protocol ContainerElement {
    var subelements:[Element] { get }
}

// MARK: Element

public class Element {
    public init() {
    }

    public var strip:Bool = false
    public var flatten:Bool = false
    public var converter:(Any -> Any?)?

    public final func parse(string:String) throws -> ParseResult {
        let scanner = Scanner(string: string)
        return try parse(scanner)
    }

    public func parse(scanner:Scanner) throws -> ParseResult {
        throw Error("Fail")
    }
}

public extension Element {
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

public class Literal: Element {
    public let value:String

    public init(_ value:String) {
        self.value = value
        super.init()
    }

    public override func parse(scanner:Scanner) -> ParseResult {
        return scanner.scanString(value) ? .Ok(self.value) : .None
    }
}

extension Literal: CustomStringConvertible {
    public var description:String {
        get {
            return "Literal(\"\(value)\")"
        }
    }
}


// MARK: Value

public class Value: Element {
    public let scan:((scanner:Scanner) -> Any?)

    public init(scan:((scanner:Scanner) -> Any?)) {
        self.scan = scan
    }

    public override func parse(scanner:Scanner) -> ParseResult {
        if let result = scan(scanner:scanner) {
            return .Ok(result)
        }
        else {
            return .None
        }
    }
}

extension Value: CustomStringConvertible {
    public var description:String {
        get {
            return "DoubleValue()"
        }
    }
}

public let cgFloatValue = Value() {
    (scanner:Scanner) -> Any? in
    return scanner.scanCGFloat()
}

public let doubleValue = Value() {
    (scanner:Scanner) -> Any? in
    return scanner.scanDouble()
}

// MARK: Range

// TODO: rename
public class RangeOf: Element {
    public let min:Int?
    public let max:Int?
    public let subelement:Element

    public init(min:Int?, max:Int?, subelement:Element) {
        self.min = min
        self.max = max
        self.subelement = subelement
        super.init()
    }

    public override func parse(scanner:Scanner) throws -> ParseResult {
        var compoundResult:[Any] = []

        loop: while true {

            if let max = max where compoundResult.count == max {
                break loop
            }

            let result = try subelement.parse(scanner)
            switch result {
                case .Ok(let value):
                    compoundResult.append(value)
                case .None:
                    break loop
            }
        }

        if let min = min where compoundResult.count < min {
            throw Error("Could not scan enough")
        }

        if flatten {
            if compoundResult.count == 1 {
                return .Ok(compoundResult[0])
            }
            else if compoundResult.count == 0 {
                return .Ok(Void)
            }
            else {
                throw Error("Could not flatten")
            }
        }

        return .Ok(compoundResult)
    }
}

extension RangeOf: CustomStringConvertible {
    public var description:String {
        get {
            return "RangeOf(\"\(subelement)\")"
        }
    }
}

extension RangeOf: ContainerElement {
    public var subelements:[Element] {
        get {
            return [subelement]
        }
    }
}

public func zeroOrOne(subelement:Element) -> RangeOf {
    let rangeOf = RangeOf(min:0, max:1, subelement:subelement)
    rangeOf.flatten = true
    return rangeOf
}

public func oneOrMore(subelement:Element) -> RangeOf {
    let rangeOf = RangeOf(min:1, max:nil, subelement:subelement)
    return rangeOf
}

// MARK: OneOf

public class OneOf: Element {
    public let subelements:[Element]

    public init(_ subelements:[Element]) {
        self.subelements = subelements
        super.init()
    }

    public override func parse(scanner:Scanner) throws -> ParseResult {
        for element in subelements {
            let result = try element.parse(scanner)
            if result.isOK {
                return result
            }
        }
        return .None
    }
}

extension OneOf: CustomStringConvertible {
    public var description:String {
        get {
            let elementDescriptions = subelements.map() { return String($0) }
            return "OneOf(\"\(elementDescriptions)\")"
        }
    }
}

extension OneOf: ContainerElement {
}

// MARK: Compound

public class Compound: Element {
    public let subelements:[Element]

    public init(_ subelements:[Element]) {
        assert(subelements.count > 0)
        self.subelements = subelements
        super.init()
    }

    public override func parse(scanner:Scanner) throws -> ParseResult {
        var compoundResult:[Any] = []
        loop: for element in subelements {
            if scanner.atEnd {
                break
            }
            let result = try element.parse(scanner)
            switch result {
                case .Ok(let value):
                    if element.strip == false {
                        compoundResult.append(value)
                    }
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
                throw Error("couldn't flatten")
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
                throw Error("Failed to convert")
            }
        }

        return result
    }
}

extension Compound: CustomStringConvertible {
    public var description:String {
        get {
            let elementDescriptions = subelements.map() { return String($0) }
            return "Compound(\"\(elementDescriptions)\")"
        }
    }
}

extension Compound: ContainerElement {
}

// MARK: AtEnd

public class AtEnd: Element {

    public override func parse(scanner:Scanner) throws -> ParseResult {
        if scanner.atEnd {
            return .Ok(Void)
        }
        else {
            throw Error("Not at end")
        }
    }

}

public let atEnd = AtEnd()

// MARK: Covenience operators

public func | (lhs:Element, rhs:Element) -> OneOf {
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

public func + (lhs:Element, rhs:Element) -> Compound {
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