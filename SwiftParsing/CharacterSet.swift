//
//  CharacterSet.swift
//  SwiftParsing
//
//  Created by Jonathan Wight on 3/16/15.
//  Copyright (c) 2015 schwa. All rights reserved.
//

import Foundation

public struct CharacterSet {
    public let set:Set <Character>

    public init(string:String) {
        var set = Set <Character> ()
        for character in string.characters {
            set.insert(character)
        }
        self.set = set
    }

    public func contains(member:Character) -> Bool {
        return set.contains(member)
    }
}

// TODO: Move
public let whiteSpaceCharacterSet = CharacterSet(string: " \t\\n\r")