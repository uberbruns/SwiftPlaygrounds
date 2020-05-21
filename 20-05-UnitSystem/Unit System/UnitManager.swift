//
//  UnitSolver.swift
//  Unit System
//
//  Created by Karsten Bruns on 10.05.20.
//  Copyright © 2020 Karsten Bruns. All rights reserved.
//

import Foundation


class UnitManager {

    private var registeredUnits = [Any]()
    private var unsatisfiedUnits = Set<AnyUnit>()
    private var unsatisfiableUnits = Set<AnyUnit>()
    private var satisfiedUnits = Set<AnyUnit>()

    private var needsUpdate = false
    private var isUpdating = false

    func register<U: Unit>(_ unitType: U.Type) {
        registeredUnits.append(unitType)
    }


    func resolve<U: Unit>(_ unitType: U.Type) -> U {
        resolve(unitType.requirement())
    }


    func resolve<U: Unit>(_ requirement: Requirement<U>) -> U {
        for unit in satisfiedUnits where requirement.isSatisfied(unit) {
            return unit.base as! U
        }


        let control = UnitControl(manager: self)
        if let unit = requirement.instantiateUnit(control: control) {
            startUnit(AnyUnit(unit))
            return unit
        }

        fatalError()
    }


    private func startUnit(_ anyUnit: AnyUnit) {
        unsatisfiedUnits.insert(anyUnit)
        update()
    }


    private func stopUnit(_ anyUnit: AnyUnit) {
        satisfiedUnits.remove(anyUnit)
        update()
    }


    func setNeedsUpdate() {
        guard needsUpdate == false else { return }
        
        needsUpdate = true
        update()
    }


    private func update() {
        guard !isUpdating else {
            setNeedsUpdate()
            return
        }

        defer {
            isUpdating = false
            if needsUpdate {
                update()
            }
        }

        isUpdating = true
        needsUpdate = false

        // A list of unsatisfied requirements across multiple units used
        // to instantiate new units.
        var allUnsatisfiedRequirements = Set<AnyRequirement>()

        // Try to resolve all unsatisfied units by resolving their unsatisfied requirements
        // using the set of satisfied units.
        for unsatisfiedUnit in unsatisfiedUnits {
            var resolvedUnits = ResolvedUnits()

            // Iterate over unsatisfied requirements and remove a requirement
            // when it was satisfied.
            let unsatisfiedRequirements = unsatisfiedUnit.control.requirements.filter { unsatisfiedRequirement in
                for satisfiedUnit in satisfiedUnits {
                    if unsatisfiedRequirement.isSatisfied(satisfiedUnit) {
                        resolvedUnits.store[unsatisfiedRequirement] = satisfiedUnit
                        return false
                    }
                }
                allUnsatisfiedRequirements.insert(unsatisfiedRequirement)
                return true
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
                setNeedsUpdate()
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
            for registeredUnit in registeredUnits {
                for newRequirement in allUnsatisfiedRequirements {
                    let control = UnitControl(manager: self)
                    if let newUnit = newRequirement.instantiateUnit(registeredUnit, control: control) {
                        unsatisfiedUnits.insert(newUnit)
                        setNeedsUpdate()
                    }
                }
            }
        }
    }
}



struct ResolvedUnits {
    fileprivate var store = [AnyRequirement: AnyUnit]()
    subscript <U>(_ requirement: Requirement<U>) -> U {
        return store[AnyRequirement(requirement)]!.base as! U
    }
}
