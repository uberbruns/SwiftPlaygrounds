//
//  PropertyWrappers.swift
//  Unit System
//
//  Created by Karsten Bruns on 17.05.20.
//  Copyright © 2020 Karsten Bruns. All rights reserved.
//

import Foundation


protocol UnitProperty {
    associatedtype Value: Equatable
    var wrappedValue: Value { get }
}


protocol UnitIdentifier {
    var rawId: Int { get }
}


@propertyWrapper
struct Id<R: Hashable>: UnitProperty, UnitIdentifier {
    var rawId: Int {
        value.hashValue
    }

    private var value: R

    var wrappedValue: R {
        get {
            value
        }
        set {
            value = newValue
        }
    }

    public var projectedValue: Id<R> {
        get { self }
    }

    init(wrappedValue: R) {
        self.value = wrappedValue
    }
}


@propertyWrapper
struct Output<R: Equatable>: UnitProperty {
    private var value: R

    var wrappedValue: R {
        get {
            value
        }
        set {
            value = newValue
        }
    }

    public var projectedValue: Output<R> {
        get { self }
    }

    init(wrappedValue: R) {
        self.value = wrappedValue
    }
}
