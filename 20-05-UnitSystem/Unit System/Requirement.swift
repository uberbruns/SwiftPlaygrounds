//
//  Requirement.swift
//  Unit System
//
//  Created by Karsten Bruns on 10.05.20.
//  Copyright © 2020 Karsten Bruns. All rights reserved.
//

import Foundation


struct Requirement<U: Unit>: Hashable {
    
    private let isSatisfiedHandler: (AnyUnit) -> Bool
    private let keyPathValuePairs: [(keyPath: AnyKeyPath, value: AnyHashable)]


    fileprivate init<V: Hashable, UP: UnitProperty>(_ keyPath: KeyPath<U, UP>, _ value: V) where UP.Value == V {
        self.keyPathValuePairs = [(keyPath, value)]

        self.isSatisfiedHandler = { anyUnit in
            guard let unit = anyUnit.base as? U else {
                return false
            }
            return unit[keyPath: keyPath].wrappedValue == value
        }
    }


    fileprivate init(_ type: U.Type) {
        self.keyPathValuePairs = []

        self.isSatisfiedHandler = { anyUnit in
            return anyUnit.base is U.Type
        }
    }


    fileprivate init(
        isSatisfiedHandler: @escaping (AnyUnit) -> Bool,
        keyPathValuePairs: [(keyPath: AnyKeyPath, value: AnyHashable)]
    ) {
        self.keyPathValuePairs = keyPathValuePairs
        self.isSatisfiedHandler = isSatisfiedHandler
    }


    func isSatisfied(_ unit: AnyUnit) -> Bool {
        isSatisfiedHandler(unit)
    }


    func isSatisfied(_ unit: U) -> Bool {
        isSatisfiedHandler(AnyUnit(unit))
    }


    func instantiateUnit(control: UnitControl) -> U? {
        do {
            return try U.self.init(requirement: self, control: control)
        } catch {
            return nil
        }
    }


    func value<V: Equatable>(for keyPath: KeyPath<U, Id<V>>) throws -> V {
        for (thisKeyPath, thisValue) in keyPathValuePairs {
            if keyPath == thisKeyPath, let value = thisValue.base as? V {
                return value
            }
        }
        throw RequirementError.expectedValueNotFound
    }


    func hash(into hasher: inout Hasher) {
        for (thisKeyPath, thisValue) in keyPathValuePairs {
            hasher.combine(thisKeyPath)
            hasher.combine(thisValue)
        }
    }


    static func == (lhs: Requirement, rhs: Requirement) -> Bool {
        lhs.hashValue == rhs.hashValue
    }


    func union(_ otherRequirement: Requirement) -> Requirement {
        Requirement(
            isSatisfiedHandler: { self.isSatisfiedHandler($0) && otherRequirement.isSatisfiedHandler($0) },
            keyPathValuePairs: keyPathValuePairs + otherRequirement.keyPathValuePairs
        )
    }


    func and<V: Hashable, UP: UnitProperty>(where keyPath: KeyPath<U, UP>, equals value: V) -> Requirement where UP.Value == V {
        let newRequirement = Requirement(keyPath, value)
        return union(newRequirement)
    }
}


struct AnyRequirement: Hashable {
    let base: Any

    private let _hashValue: Int
    private let isSatisfiedHandler: (AnyUnit) -> Bool
    private let instantiateUnitHandler: (UnitControl) -> AnyUnit?


    init<U: Unit>(_ base: Requirement<U>) {
        self.base = base
        self._hashValue = base.hashValue
        self.isSatisfiedHandler = { anyUnit in
            base.isSatisfied(anyUnit)
        }
        self.instantiateUnitHandler = { unitControl in
            base.instantiateUnit(control: unitControl).map(AnyUnit.init)
        }
    }


    func isSatisfied(_ unit: AnyUnit) -> Bool {
        isSatisfiedHandler(unit)
    }


    func instantiateUnit(_ unitType: Any, control: UnitControl) -> AnyUnit? {
        instantiateUnitHandler(control)
    }


    static func ==(lhs: AnyRequirement, rhs: AnyRequirement) -> Bool {
        lhs._hashValue == rhs._hashValue
    }

    
    func hash(into hasher: inout Hasher) {
        hasher.combine(_hashValue)
    }
}


enum RequirementError: Error {
    case expectedValueNotFound
}


extension Unit {
    static func requirement() -> Requirement<Self> {
        Requirement(Self.self)
    }

    static func requirement<V: Hashable, UP: UnitProperty>(where keyPath: KeyPath<Self, UP>, equals value: V) -> Requirement<Self> where UP.Value == V {
        Requirement(keyPath, value)
    }
}
