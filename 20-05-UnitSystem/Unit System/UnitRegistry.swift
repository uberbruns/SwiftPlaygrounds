//
//  UnitSolver.swift
//  Unit System
//
//  Created by Karsten Bruns on 10.05.20.
//  Copyright © 2020 Karsten Bruns. All rights reserved.
//

import Foundation


class UnitRegistry {

    private var registeredUnits = [Any]()
    private var unsatisfiedUnits = Set<AnyUnit>()
    private var unsatisfiableUnits = Set<AnyUnit>()
    private var satisfiedUnits = Set<AnyUnit>()


    func register<U: Unit>(_ unitType: U.Type) {
        registeredUnits.append(unitType)
    }


    func dequeue<U: Unit>(_ unitType: U.Type) -> U {
        dequeue(unitType, for: unitType.required())
    }


    func dequeue<U: Unit, V: Hashable>(_ keyPath: KeyPath<U, Output<V>>, _ value: V) -> U {
        dequeue(U.self, for: U.required(where: keyPath, equals: value))
    }


    func dequeue<U: Unit>(_ unitType: U.Type, for requirement: Requirement) -> U {
        for unit in satisfiedUnits where requirement.isSatisfied(unit) {
            return unit.base as! U
        }

        if let unit = requirement.instantiateUnit(unitType) {
            dequeueUnit(unit)
            return unit.base as! U
        }

        fatalError()
    }


    private func dequeueUnit(_ anyUnit: AnyUnit) {
        unsatisfiedUnits.insert(anyUnit)
        update()
    }


    private func stopUnit(_ anyUnit: AnyUnit) {
        satisfiedUnits.remove(anyUnit)
        update()
    }


    private func update() {
        // A list of unsatisfied requirements across multiple units used
        // to instantiate new units.
        var allUnsatisfiedRequirements = Set<Requirement>()

        // Try to resolve all unsatisfied units by resolving their unsatisfied requirements
        // with the set of satisfied units.
        for unsatisfiedUnit in unsatisfiedUnits {
            var resolvedUnits = ResolvedUnits()
            var unsatisfiedRequirements = unsatisfiedUnit.requirements

            // Iterate over unsatisfied requirements and remove a requirement
            // when it could be satisfied.
            unsatisfiedRequirements.removeAll { unsatisfiedRequirement in
                for satisfiedUnit in satisfiedUnits {
                    if unsatisfiedRequirement.isSatisfied(satisfiedUnit) {
                        resolvedUnits.store[unsatisfiedRequirement] = satisfiedUnit
                        return true
                    }
                }
                allUnsatisfiedRequirements.insert(unsatisfiedRequirement)
                return false
            }

            let allRequirementsSatisfied = unsatisfiedRequirements.isEmpty
            if allRequirementsSatisfied {
                // Move unit from the unsatisfied set into the satisfied one.
                unsatisfiedUnits.remove(unsatisfiedUnit)
                satisfiedUnits.insert(unsatisfiedUnit)

                // Move unsatisfiable units to unsatisfied set, so they are
                // reevaluated again.
                unsatisfiedUnits.formUnion(unsatisfiableUnits)
                unsatisfiableUnits.removeAll()

                // Notify satisfied unit
                unsatisfiedUnit.requirementsSatisfied(resolvedUnits: resolvedUnits)

                // Kick off fresh update cycle
                update()
                return
            } else {
                // The unit is considered _unsatisfiable_ until another unit
                // was resolved.
                unsatisfiedUnits.remove(unsatisfiedUnit)
                unsatisfiableUnits.insert(unsatisfiedUnit)
            }
        }

        // Try to instantiate new units based upon unsatisfied requirements and
        // the registered units.
        if !allUnsatisfiedRequirements.isEmpty {
            var needsUpdate = false
            for registeredUnit in registeredUnits {
                for newRequirement in allUnsatisfiedRequirements {
                    if let newUnit = newRequirement.instantiateUnit(registeredUnit) {
                        unsatisfiedUnits.insert(newUnit)
                        needsUpdate = true
                    }
                }
            }
            if needsUpdate {
                update()
            }
        }
    }
}



struct ResolvedUnits {
    fileprivate var store = [Requirement: AnyUnit]()
    subscript <U>(_ requirement: Requirement) -> U {
        return store[requirement]!.base as! U
    }
}



struct UnitControl {
    fileprivate weak var system: UnitRegistry?
}
