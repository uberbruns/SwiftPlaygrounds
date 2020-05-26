//
//  UnitProperty+Fixed.swift
//  Unit System
//
//  Created by Karsten Bruns on 22.05.20.
//  Copyright © 2020 Karsten Bruns. All rights reserved.
//

import Foundation


protocol DistinctUnitProperty: AnyObject {
    var intIdentifier: Int { get }
}


@propertyWrapper
final class Distinct<V: Hashable>: UnitProperty, DistinctUnitProperty {
    var intIdentifier: Int {
        value.hashValue
    }

    private var value: V

    var wrappedValue: V {
        get {
            value
        }
        set {
            value = newValue
        }
    }

    public var projectedValue: Distinct<V> {
        get { self }
    }

    init(wrappedValue: V) {
        self.value = wrappedValue
    }
}
