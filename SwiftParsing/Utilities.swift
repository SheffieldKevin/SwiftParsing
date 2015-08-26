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

