//
//  Swift+Extensions.swift
//  Unit System
//
//  Created by Karsten Bruns on 16.05.20.
//  Copyright © 2020 Karsten Bruns. All rights reserved.
//

import Foundation

extension Error {
    /// This extension is useful when unwrapping optionals inside a do/catch-context.
    /// It allows you to throw an error when an optional cannot be unwrapped.
    ///
    /// - Usage: `let myValue = someOptional ?? MyError().throw()`
    func `throw`<T>() throws -> T {
        throw self
    }
}


struct LazyError: Error {
}
