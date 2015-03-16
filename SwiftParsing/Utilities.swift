//
//  Utilities.swift
//  SwiftParsing
//
//  Created by Jonathan Wight on 3/16/15.
//  Copyright (c) 2015 schwa. All rights reserved.
//

import Foundation


extension Double {
    static let formatter = NSNumberFormatter()
    static func fromString(string:String) -> Double? {
        let number = formatter.numberFromString(string)
        if let number = number {
            return number.doubleValue
        }
        else {
            return nil
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
    let description = reflect(element).summary
//    let description = toString(element)

    let spaces = reduce(0..<depth, "") {
        (U:String, index:Int) -> String in
        return U + "  "
        }
    println("\(spaces)\(description)")
    if let childElements = children(element) {
        for child in childElements {
            dump(child, depth:depth + 1, children)
        }
    }
}

extension Element {
    func dump() {
        SwiftParsing.dump(self, depth: 0, getChildren)
    }
}