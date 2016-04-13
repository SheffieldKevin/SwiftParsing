//
//  JSONPathParsingTests.swift
//  SwiftParsing
//
//  Created by Jonathan Wight on 10/12/15.
//  Copyright © 2015 schwa. All rights reserved.
//

import XCTest

import SwiftParsing

let rootOperator = Literal("$").makeStripped()
let childOperator = Literal(".").makeStripped()
let wildcardSelector = Literal("*")
let nameSelector = try! Pattern("[A-Za-z]+")
let selector = (wildcardSelector | nameSelector).makeFlattened()

//let LEFT_BRACKET = Literal("[").makeStripped()
//let RIGHT_BRACKET = Literal("]").makeStripped()
//let integer = try! Pattern("[0-9]+")
//let `subscript` = LEFT_BRACKET + integer + RIGHT_BRACKET

//let pathElement = (childOperator + selector).makeFlattened() + zeroOrOne(`subscript`)
let pathElement = (childOperator + selector).makeFlattened()

let path = ((rootOperator + oneOrMore(pathElement)).makeFlattened() + atEnd).makeFlattened()



class JSONPathParsingTests: XCTestCase {
    func testExample() {
        let result = try! path.parse("$.foo")
        print(result)
    }
}
