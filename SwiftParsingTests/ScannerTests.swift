//
//  ScannerTests.swift
//  SwiftParsing
//
//  Created by Jonathan Wight on 8/25/15.
//  Copyright © 2015 schwa. All rights reserved.
//

import XCTest

import SwiftParsing

func XCTAssertNoThrow(block:() throws -> Void) {
    do {
        try block()
    }
    catch {
        XCTAssertTrue(false)
    }
}

func XCTAssertThrows(block:() throws -> Void) {
    do {
        try block()
    }
    catch {
        return
    }
    XCTAssertTrue(false)
}



class ScannerTests: XCTestCase {

    func testScanSimpleString() {
        let scanner = Scanner(string: "Hello world")
        XCTAssert(scanner.scanString("Hello") == true)
        XCTAssert(scanner.scanString("world") == true)
        XCTAssert(scanner.atEnd == true)
    }

    func testScanTooMuchSimpleString() {
        let scanner = Scanner(string: "Hello")
        XCTAssert(scanner.scanString("Hello world") == false)
        XCTAssert(scanner.atEnd == false)
    }

    func testScanCharSet() {
        let scanner = Scanner(string: "01234")
        XCTAssert(scanner.scanCharactersFromSet(CharacterSet(string: "0123456789")) == "01234")
        XCTAssert(scanner.atEnd == true)
    }

    func testBadScanCharSet() {
        let scanner = Scanner(string: "abcde")
        XCTAssert(scanner.scanCharactersFromSet(CharacterSet(string: "0123456789")) == nil)
        XCTAssert(scanner.atEnd == false)
    }

    func testScanSingleCharSet() {
        let scanner = Scanner(string: "0")
        XCTAssert(scanner.scanCharacterFromSet(CharacterSet(string: "0123456789")) == Character("0"))
        XCTAssert(scanner.atEnd == true)
    }

    func testScanNoSingleCharSet() {
        let scanner = Scanner(string: "A")
        XCTAssert(scanner.scanCharacterFromSet(CharacterSet(string: "0123456789")) == nil)
        XCTAssert(scanner.atEnd == false)
    }

    func testScanSingleChar() {
        let scanner = Scanner(string: "0A")
        XCTAssert(scanner.scanCharacter(Character("0")) == true)
        XCTAssert(scanner.scanCharacter(Character("X")) == false)
    }

    func testScanSimpleStringNoSkip() {
        let scanner = Scanner(string: "Hello world")
        scanner.skippedCharacters = nil
        XCTAssert(scanner.scanString("Hello") == true)
        XCTAssert(scanner.scanString(" ") == true)
        XCTAssert(scanner.scanString("world") == true)
        XCTAssert(scanner.atEnd == true)
    }

    func testScanSuppressSkip() {
        let scanner = Scanner(string: "Hello world")
        scanner.suppressSkip() {
            XCTAssert(scanner.scanString("Hello") == true)
            XCTAssert(scanner.scanString(" ") == true)
            XCTAssert(scanner.scanString("world") == true)
            XCTAssert(scanner.atEnd == true)
        }
    }

    func testScanBadBack() {
        let scanner = Scanner(string: "")
        XCTAssertThrows {
            try scanner.back()
        }
    }


    func testScanRegularExpression() {

        let scanner = Scanner(string: "Hello world")
        let result = try! scanner.scanRegularExpression("H[^\\s]+")
        XCTAssert(result == "Hello")
        XCTAssert(scanner.remaining == " world")

        let result2 = try! scanner.scanRegularExpression("w[^\\s]+")
        XCTAssert(result2 == "world")

    }

    func testScanNotRegularExpression() {

        let scanner = Scanner(string: "Hello world")
        let result = try! scanner.scanRegularExpression("[0-9]+")
        XCTAssert(result == nil)

    }
}
