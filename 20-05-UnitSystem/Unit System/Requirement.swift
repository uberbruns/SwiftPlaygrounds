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
        let isOutput: Bool
        let isSatisfied: (AnyUnit) -> Bool
    }


    // MARK: Properties

    private let subRequirements: [SubRequirement]


    // MARK: Life Cycle

    fileprivate init(_ type: U.Type) {
        let isSatisfied: (AnyUnit) -> Bool = { anyUnit in
            return anyUnit.base is U.Type
        }
        self.subRequirements = [SubRequirement(keyPath: nil, value: nil, isOutput: false, isSatisfied: isSatisfied)]
    }


    private init<V: Hashable, UP: UnitProperty>(_ keyPath: KeyPath<U, UP>, _ value: V, isOutput: Bool) where UP.Value == V {
        let isSatisfied: (AnyUnit) -> Bool = { anyUnit in
            guard let unit = anyUnit.base as? U else {
                return false
            }
            return unit[keyPath: keyPath].wrappedValue == value
        }

        self.subRequirements = [
            SubRequirement(
                keyPath: keyPath,
                value: value,
                isOutput: isOutput,
                isSatisfied: isSatisfied
            )
        ]
    }


    fileprivate init<V: Hashable>(_ keyPath: KeyPath<U, Id<V>>, _ value: V) {
        self = .init(keyPath, value, isOutput: false)
    }


    fileprivate init<V: Hashable>(_ keyPath: KeyPath<U, Output<V>>, _ value: V) {
        self = .init(keyPath, value, isOutput: true)
    }


    private init(subRequirements: [SubRequirement]) {
        self.subRequirements = subRequirements
    }


    // MARK: Core API

    func satisfactionLevel(for unit: AnyUnit) -> SatisfactionLevel {
        var result = SatisfactionLevel.full
        for subRequirement in subRequirements {
            switch (subRequirement.isOutput, subRequirement.isSatisfied(unit)) {
            case (_, true):
                // Go on -> Keep `result`
                break
            case (true, false):
                // Unsatisfied Output -> Downgrade Level
                result = .identity
            case (false, false):
                // Unsatisfied Identity -> Early exit
                return .unsatisfied
            }
        }
        return result
    }


    func instantiateUnit(link: UnitLink) -> U? {
        do {
            return try U.self.init(requirement: self, link: link)
        } catch {
            return nil
        }
    }


    func value<V: Equatable>(for keyPath: KeyPath<U, Id<V>>) throws -> V {
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

    func and<V: Hashable>(where keyPath: KeyPath<U, Id<V>>, equals value: V) -> Requirement {
        let newRequirement = Requirement(keyPath, value)
        return union(newRequirement)
    }


    func and<V: Hashable>(where keyPath: KeyPath<U, Output<V>>, equals value: V) -> Requirement {
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
    private let satisfactionLevelFunc: (AnyUnit) -> SatisfactionLevel
    private let instantiateUnitFunc: (UnitLink) -> AnyUnit?


    // MARK: Properties: Life Cycle

    init<U: Unit>(_ base: Requirement<U>) {
        self.base = base
        self.baseHashValue = base.hashValue
        self.satisfactionLevelFunc = { anyUnit in
            base.satisfactionLevel(for: anyUnit)
        }
        self.instantiateUnitFunc = { unitControl in
            base.instantiateUnit(link: unitControl).map(AnyUnit.init)
        }
    }


    // MARK: Core API

    func satisfactionLevel(with unit: AnyUnit) -> SatisfactionLevel {
        satisfactionLevelFunc(unit)
    }


    func instantiateUnit(_ unitType: Any, link: UnitLink) -> AnyUnit? {
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
    case identity
    case full

    var isIdentitySatisfied: Bool {
        switch self {
        case .unsatisfied:
            return false
        case .full, .identity:
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

    static func requirement<V: Hashable>(where keyPath: KeyPath<Self, Id<V>>, equals value: V) -> Requirement<Self> {
        Requirement(keyPath, value)
    }

    static func requirement<V: Hashable>(where keyPath: KeyPath<Self, Output<V>>, equals value: V) -> Requirement<Self> {
        Requirement(keyPath, value)
    }
}
