//
//  UnitProperty+Fixed.swift
//  Unit System
//
//  Created by Karsten Bruns on 22.05.20.
//  Copyright © 2020 Karsten Bruns. All rights reserved.
//

import Foundation


protocol HardUnitProperty {
    var hashValue: Int { get }
}


@propertyWrapper
final class Hard<V: Hashable>: UnitProperty, HardUnitProperty {
    var hashValue: Int {
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

    public var projectedValue: Hard<V> {
        get { self }
    }

    init(wrappedValue: V) {
        self.value = wrappedValue
    }
}
