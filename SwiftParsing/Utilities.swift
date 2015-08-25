//
//  Utilities.swift
//  SwiftParsing
//
//  Created by Jonathan Wight on 3/16/15.
//  Copyright (c) 2015 schwa. All rights reserved.
//

import Foundation

import SwiftUtilities

extension Double {
    static let formatter = NSNumberFormatter()
    static func fromString(string:String) throws -> Double {
        let number = formatter.numberFromString(string)
        if let number = number {
            return number.doubleValue
        }
        else {
            throw SwiftUtilities.Error.generic("Could not convert into double")
        }
    }
}

func getChildren(element:Element) -> [Element]? {
    if let element = element as? ContainerElement {
        return element.subelements
    }
    return nil
}

func dump <T> (element:T, depth:Int = 0, children:T -> [T]?) {
    let description = String(element)

    let spaces = (0..<depth).reduce("") {
        (U:String, index:Int) -> String in
        return U + "  "
        }
    print("\(spaces)\(description)")
    if let childElements = children(element) {
        for child in childElements {
            dump(child, depth:depth + 1, children: children)
        }
    }
}

extension Element {
    func dump() {
        SwiftParsing.dump(self, depth: 0, children: getChildren)
    }
}