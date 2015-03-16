//
//  CharacterSet.swift
//  SwiftParsing
//
//  Created by Jonathan Wight on 3/16/15.
//  Copyright (c) 2015 schwa. All rights reserved.
//

import Foundation

struct CharacterSet {
    let set:Set <Character>

    init(string:String) {
        var set = Set <Character> ()
        for character in string {
            set.insert(character)
        }
        self.set = set
    }

    func contains(member:Character) -> Bool {
        return set.contains(member)
    }
}

let whiteSpaceCharacterSet = CharacterSet(string: " \t\\n\r")