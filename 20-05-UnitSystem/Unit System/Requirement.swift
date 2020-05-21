//
//  Requirement.swift
//  Unit System
//
//  Created by Karsten Bruns on 10.05.20.
//  Copyright © 2020 Karsten Bruns. All rights reserved.
//

import Foundation


struct Requirement: Hashable {
    
    private let isSatisfiedHandler: (AnyUnit) -> Bool
    private let instantiateUnitHandler: (Any, Requirement) throws -> AnyUnit?
    private let keyPathValuePairs: [(keyPath: AnyKeyPath, value: AnyHashable)]


    fileprivate init<U: Unit, V: Hashable, UP: UnitProperty>(_ keyPath: KeyPath<U, UP>, _ value: V) where UP.Value == V {
        self.keyPathValuePairs = [(keyPath, value)]

        self.isSatisfiedHandler = { anyUnit in
            guard let unit = anyUnit.base as? U else {
                return false
            }
            return unit[keyPath: keyPath].wrappedValue == value
        }

        self.instantiateUnitHandler = { any, requirement in
            guard let unitType = any as? U.Type else {
                return nil
            }

            let unit = try unitType.init(requirement: requirement)
            return AnyUnit(unit)
        }
    }


    fileprivate init<U: Unit>(_ type: U.Type) {
        self.keyPathValuePairs = []

        self.isSatisfiedHandler = { anyUnit in
            return anyUnit.base is U.Type
        }

        self.instantiateUnitHandler = { any, requirement in
            guard let unitType = any as? U.Type else {
                return nil
            }

            let unit = try unitType.init(requirement: requirement)
            return AnyUnit(unit)
        }
    }


    fileprivate init(
        isSatisfiedHandler: @escaping (AnyUnit) -> Bool,
        instantiateUnitHandler: @escaping (Any, Requirement) throws -> AnyUnit?,
        keyPathValuePairs: [(keyPath: AnyKeyPath, value: AnyHashable)]
    ) {
        self.keyPathValuePairs = keyPathValuePairs
        self.isSatisfiedHandler = isSatisfiedHandler
        self.instantiateUnitHandler = instantiateUnitHandler
    }


    func isSatisfied(_ unit: AnyUnit) -> Bool {
        isSatisfiedHandler(unit)
    }


    func isSatisfied<U: Unit>(_ unit: U) -> Bool {
        isSatisfiedHandler(AnyUnit(unit))
    }


    func instantiateUnit(_ unitType: Any) -> AnyUnit? {
        do {
            return try instantiateUnitHandler(unitType, self)
        } catch {
            return nil
        }
    }


    func get<U: Unit, V: Equatable>(_ keyPath: KeyPath<U, Id<V>>) throws -> V {
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
            instantiateUnitHandler: instantiateUnitHandler,
            keyPathValuePairs: keyPathValuePairs + otherRequirement.keyPathValuePairs
        )
    }


    func and<U: Unit, V: Hashable, UP: UnitProperty>(where keyPath: KeyPath<U, UP>, equals value: V) -> Requirement where UP.Value == V {
        let newRequirement = Requirement(keyPath, value)
        return union(newRequirement)
    }
}


struct RequirementsTable<Key> {

    subscript(_ key: Key) -> Requirement {
        get {
            fatalError()
        }
        set {
            fatalError()
        }
    }
}


enum RequirementError: Error {
    case expectedValueNotFound
}


extension Unit {
    static func required() -> Requirement {
        Requirement(Self.self)
    }

    static func required<V: Hashable, UP: UnitProperty>(where keyPath: KeyPath<Self, UP>, equals value: V) -> Requirement where UP.Value == V {
        Requirement(keyPath, value)
    }
}
