//
//  UnitProperty+Id.swift
//  Unit System
//
//  Created by Karsten Bruns on 22.05.20.
//  Copyright © 2020 Karsten Bruns. All rights reserved.
//

import Foundation


protocol UnitId {
    var hashValue: Int { get }
}


@propertyWrapper
final class Id<V: Hashable>: UnitProperty, UnitId {
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

    public var projectedValue: Id<V> {
        get { self }
    }

    init(wrappedValue: V) {
        self.value = wrappedValue
    }
}
