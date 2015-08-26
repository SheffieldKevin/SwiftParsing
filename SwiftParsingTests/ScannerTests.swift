//
//  ScannerTests.swift
//  SwiftParsing
//
//  Created by Jonathan Wight on 8/25/15.
//  Copyright © 2015 schwa. All rights reserved.
//

import XCTest

import SwiftParsing

class ScannerTests: XCTestCase {

    func testScanSimpleString() {
        let scanner = Scanner(string: "Hello world")
        XCTAssert(scanner.scanString("Hello") == true)
        XCTAssert(scanner.scanString("world") == true)
        XCTAssert(scanner.atEnd == true)
    }

    func testScanSimpleStringNoSkip() {
        let scanner = Scanner(string: "Hello world")
        scanner.skippedCharacters = nil
        XCTAssert(scanner.scanString("Hello") == true)
        XCTAssert(scanner.scanString(" ") == true)
        XCTAssert(scanner.scanString("world") == true)
        XCTAssert(scanner.atEnd == true)
    }


    func testScanRegularExpression() {

        let scanner = Scanner(string: "Hello world")
        let result = try! scanner.scanRegularExpression("H[^\\s]+")
        XCTAssert(result == "Hello")
        XCTAssert(scanner.remaining == " world")

        let result2 = try! scanner.scanRegularExpression("w[^\\s]+")
        XCTAssert(result2 == "world")

    }
}
