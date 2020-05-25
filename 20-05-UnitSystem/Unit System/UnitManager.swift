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
    private var unsatisfiedUnits = Set<UnitRef>()
    private var unsatisfiableUnits = Set<UnitRef>()
    private var satisfiedUnits = [UnitRef]()
    private var fullySatisfiedSet = Set<Int>()
    private var stronglyReferencedUnits = [Int: UnitObject]()

    private var needsUpdate = false
    private var isUpdating = false

    
    func register<U: Unit>(_ unitType: U.Type) {
        registeredUnits.append(unitType)
    }


    @discardableResult
    func resolve<U: Unit>(_ unitType: U.Type) -> U {
        resolve(unitType.requirement())
    }

    
    @discardableResult
    func resolve<U: Unit>(_ requirement: Requirement<U>) -> U {
        for unit in satisfiedUnits where requirement.satisfaction(with: unit).hardPropertiesAreSatisfied {
            return unit.object as! U
        }

        let link = UnitLink(manager: self)
        if let (unit, unitRef) = requirement.instantiateUnit(link: link) {
            unsatisfiedUnits.insert(unitRef)
            stronglyReferencedUnits[unit.id] = unit
            update()
            return unit
        }

        fatalError()
    }

    func removeUnit(_ unitRef: UnitRef) {
        if let index = satisfiedUnits.firstIndex(of: unitRef)  {
            satisfiedUnits.remove(at: index)
        }

        if let index = unsatisfiedUnits.firstIndex(of: unitRef)  {
            unsatisfiedUnits.remove(at: index)
        }
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
            } else {
                stronglyReferencedUnits.removeAll()
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
            // Iterate over unsatisfied requirements and remove a requirement
            // when it was satisfied.
            let unsatisfiedRequirements = unsatisfiedUnit.requirements.filter { unsatisfiedRequirement in
                for satisfiedUnit in satisfiedUnits {
                    if unsatisfiedRequirement.satisfaction(with: satisfiedUnit).hardPropertiesAreSatisfied {
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
                satisfiedUnits.append(unsatisfiedUnit)

                // Move unsatisfiable units to unsatisfied set, so they are
                // reevaluated again.
                unsatisfiedUnits.formUnion(unsatisfiableUnits)
                unsatisfiableUnits.removeAll()

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
                for unsatisfiedRequirement in allUnsatisfiedRequirements {
                    let isAlreadyInstantiated = unsatisfiedUnits.contains {
                        unsatisfiedRequirement.satisfaction(with: $0).hardPropertiesAreSatisfied
                    }

                    guard !isAlreadyInstantiated else {
                        continue
                    }

                    let link = UnitLink(manager: self)
                    if let (newUnitObject, newUnitRef) = unsatisfiedRequirement.instantiateUnit(registeredUnit, link: link) {
                        // Make sure the new unit is satisfying its init requirements
                        assert(unsatisfiedRequirement.satisfaction(with: newUnitRef).hardPropertiesAreSatisfied)

                        // Keep a strong ref, so the unit survives until updates are completed
                        stronglyReferencedUnits[newUnitObject.id] = newUnitObject

                        // Try satisfying it in next update round
                        unsatisfiedUnits.insert(newUnitRef)
                        setNeedsUpdate()
                    }
                }
            }
        }

        // Check if all requirements (incl. soft requirements) are satisfied
        for unit in satisfiedUnits {
            var resolvedUnits = ResolvedUnits()

            let requirements = unit.requirements.filter { requirement in
                for otherUnit in satisfiedUnits {
                    if requirement.satisfaction(with: otherUnit) == .hardAndSoft {
                        resolvedUnits.store[requirement] = otherUnit.object
                        return false
                    }
                }
                allUnsatisfiedRequirements.insert(requirement)
                return true
            }

            unit.object.link.resolvedUnits = resolvedUnits

            let isFullySatisfied = fullySatisfiedSet.contains(unit.id)
            let canBeFullySatisfied = requirements.isEmpty

            if isFullySatisfied != canBeFullySatisfied {
                if canBeFullySatisfied {
                    fullySatisfiedSet.insert(unit.id)
                    unit.requirementsSatisfied(resolvedUnits: resolvedUnits)
                } else {
                    fullySatisfiedSet.remove(unit.id)
                    unit.requirementsSatisfactionLost()
                }
                setNeedsUpdate()
            }
        }
    }
}



struct ResolvedUnits {
    fileprivate var store = [AnyRequirement: UnitObject]()

    subscript <U>(_ requirement: Requirement<U>) -> U {
        return store[AnyRequirement(requirement)] as! U
    }

}
