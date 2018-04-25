//
//  main.swift
//  PipeOperator
//
//  Created by Karsten Bruns on 13.02.18.
//  Copyright © 2018 bruns.me. All rights reserved.
//

import Foundation


infix operator |>: AssignmentPrecedence

public func |> <T,U>(lhs: T, rhs: (T) -> U) -> U {
    return rhs(lhs)
}

func double(a: Int) -> Int {
    return a * 2
}

let fara = 5 |> { $0 + 3 }
print(fara)
