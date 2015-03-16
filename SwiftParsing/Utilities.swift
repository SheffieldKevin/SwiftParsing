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

