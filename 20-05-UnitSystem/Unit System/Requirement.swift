//
//  Requirement.swift
//  Unit System
//
//  Created by Karsten Bruns on 10.05.20.
//  Copyright © 2020 Karsten Bruns. All rights reserved.
//

import Foundation


// MARK: - Requirement -

struct Requirement<U: Unit>: Hashable {

    // MARK: Supporting Type

    private struct SubRequirement {
        let keyPath: AnyKeyPath?
        let value: AnyHashable?
        let isSoft: Bool
        let isSatisfied: (UnitRef) -> Bool
    }


    // MARK: Properties

    private let subRequirements: [SubRequirement]


    // MARK: Life Cycle

    fileprivate init(_ type: U.Type) {
        let isSatisfied: (UnitRef) -> Bool = { unitRef in
            return unitRef.object is U
        }
        self.subRequirements = [SubRequirement(keyPath: nil, value: nil, isSoft: false, isSatisfied: isSatisfied)]
    }


    private init<V: Hashable, UP: UnitProperty>(_ keyPath: KeyPath<U, UP>, _ value: V, isSoft: Bool) where UP.Value == V {
        let isSatisfied: (UnitRef) -> Bool = { unitRef in
            guard let unit = unitRef.object as? U else {
                return false
            }
            return unit[keyPath: keyPath].wrappedValue == value
        }

        self.subRequirements = [
            SubRequirement(
                keyPath: keyPath,
                value: value,
                isSoft: isSoft,
                isSatisfied: isSatisfied
            )
        ]
    }


    fileprivate init<V: Hashable>(_ keyPath: KeyPath<U, Hard<V>>, _ value: V) {
        self = .init(keyPath, value, isSoft: false)
    }


    fileprivate init<V: Hashable>(_ keyPath: KeyPath<U, Soft<V>>, _ value: V) {
        self = .init(keyPath, value, isSoft: true)
    }


    private init(subRequirements: [SubRequirement]) {
        self.subRequirements = subRequirements
    }


    // MARK: Core API

    func satisfaction(with unit: UnitRef) -> SatisfactionLevel {
        var result = SatisfactionLevel.hardAndSoft
        for subRequirement in subRequirements {
            switch (subRequirement.isSoft, subRequirement.isSatisfied(unit)) {
            case (_, true):
                // Go on -> Keep `result`
                break
            case (true, false):
                // Unsatisfied Soft Requirement -> Downgrade Level
                result = .hardOnly
            case (false, false):
                // Unsatisfied Hard Requirement -> Early exit
                return .unsatisfied
            }
        }
        return result
    }


    func instantiateUnit(link: UnitLink) -> (U, UnitRef)? {
        do {
            let newUnit = try U.self.init(requirement: self, link: link)
            let unitRef = UnitRef(newUnit)
            link.unitRef = unitRef
            return (newUnit, unitRef)
        } catch {
            return nil
        }
    }


    func value<V: Equatable>(for keyPath: KeyPath<U, Hard<V>>) throws -> V {
        for subRequirement in subRequirements {
            if keyPath == subRequirement.keyPath, let value = subRequirement.value?.base as? V {
                return value
            }
        }
        throw RequirementError.expectedValueNotFound
    }


    func union(_ otherRequirement: Requirement) -> Requirement {
        Requirement(subRequirements: subRequirements + otherRequirement.subRequirements)
    }


    // MARK: Convenience API

    func and<V: Hashable>(where keyPath: KeyPath<U, Hard<V>>, equals value: V) -> Requirement {
        let newRequirement = Requirement(keyPath, value)
        return union(newRequirement)
    }


    func and<V: Hashable>(where keyPath: KeyPath<U, Soft<V>>, equals value: V) -> Requirement {
        let newRequirement = Requirement(keyPath, value)
        return union(newRequirement)
    }


    // MARK: Protocol Conformance: Hashable

    func hash(into hasher: inout Hasher) {
        for subRequirement in subRequirements {
            hasher.combine(subRequirement.keyPath)
            hasher.combine(subRequirement.value)
        }
    }


    static func == (lhs: Requirement, rhs: Requirement) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}



// MARK: - Requirement Type Eraser -

struct AnyRequirement: Hashable {

    // MARK: Properties: Public

    let base: Any


    // MARK: Properties: Private

    private let baseHashValue: Int
    private let satisfactionFunc: (UnitRef) -> SatisfactionLevel
    private let instantiateUnitFunc: (UnitLink) -> (UnitObject, UnitRef)?


    // MARK: Properties: Life Cycle

    init<U: Unit>(_ base: Requirement<U>) {
        self.base = base
        self.baseHashValue = base.hashValue
        self.satisfactionFunc = { unitRef in
            base.satisfaction(with: unitRef)
        }
        self.instantiateUnitFunc = { unitControl in
            return base.instantiateUnit(link: unitControl)
        }
    }


    // MARK: Core API

    func satisfaction(with unit: UnitRef) -> SatisfactionLevel {
        satisfactionFunc(unit)
    }


    func instantiateUnit(_ unitType: Any, link: UnitLink) -> (UnitObject, UnitRef)? {
        instantiateUnitFunc(link)
    }


    // MARK: Protocol Conformance: Hashable

    static func ==(lhs: AnyRequirement, rhs: AnyRequirement) -> Bool {
        lhs.baseHashValue == rhs.baseHashValue
    }

    
    func hash(into hasher: inout Hasher) {
        hasher.combine(baseHashValue)
    }
}



// MARK: - Supporting Types -

enum SatisfactionLevel: Equatable {
    case unsatisfied
    case hardOnly
    case hardAndSoft

    var hardPropertiesAreSatisfied: Bool {
        switch self {
        case .unsatisfied:
            return false
        case .hardAndSoft, .hardOnly:
            return true
        }
    }
}


enum RequirementError: Error {
    case expectedValueNotFound
}



// MARK: - Convenience Extension -

extension Unit {
    static func requirement() -> Requirement<Self> {
        Requirement(Self.self)
    }

    static func requirement<V: Hashable>(where keyPath: KeyPath<Self, Hard<V>>, equals value: V) -> Requirement<Self> {
        Requirement(keyPath, value)
    }

    static func requirement<V: Hashable>(where keyPath: KeyPath<Self, Soft<V>>, equals value: V) -> Requirement<Self> {
        Requirement(keyPath, value)
    }
}
