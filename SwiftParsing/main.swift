//
//  main.swift
//  SwiftParsing
//
//  Created by Jonathan Wight on 3/16/15.
//  Copyright (c) 2015 schwa. All rights reserved.
//

import Foundation

let range = RangeOf(min: 2, max: 3, subelement: Literal("Boing")) + atEnd


println(range.parse(""))
println(range.parse("Boing"))
println(range.parse("Boing Boing"))
println(range.parse("Boing Boing Boing"))
println(range.parse("Boing Boing Boing Boing"))
println(range.parse("Boing Boing Boing Wibble"))