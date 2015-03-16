//
//  SwiftParsingTests.swift
//  SwiftParsingTests
//
//  Created by Jonathan Wight on 3/16/15.
//  Copyright (c) 2015 schwa. All rights reserved.
//

import Cocoa
import XCTest
import SwiftParsing

let COMMA = Literal(",")
let OPT_COMMA = zeroOrOne(COMMA).makeStripped()
let LPAREN = Literal("(").makeStripped()
let RPAREN = Literal(")").makeStripped()
let VALUE_LIST = oneOrMore((cgFloatValue + OPT_COMMA).makeStripped().makeFlattened())

// TODO: Should set manual min and max value instead of relying on 0..<infinite VALUE_LIST

let matrix = (Literal("matrix") + LPAREN + VALUE_LIST + RPAREN)
let translate = (Literal("translate") + LPAREN + VALUE_LIST + RPAREN)
let scale = (Literal("scale") + LPAREN + VALUE_LIST + RPAREN)
let rotate = (Literal("rotate") + LPAREN + VALUE_LIST + RPAREN)
let skewX = (Literal("skewX") + LPAREN + VALUE_LIST + RPAREN)
let skewY = (Literal("skewY") + LPAREN + VALUE_LIST + RPAREN)
let transform = (matrix | translate | scale | rotate | skewX | skewY).makeFlattened()
let transforms = oneOrMore((transform + OPT_COMMA).makeFlattened())


class SwiftParsingTests: XCTestCase {
    
    func testExample() {
        let result = transforms.parse("translate(0,0)")
        if let value = result.value as? [Any] {
            if let value = value[0] as? [Any] {
                let type = value[0] as? String
                XCTAssertEqual(type!, "translate")
                // TODO now values
            }
        }
    }
}

