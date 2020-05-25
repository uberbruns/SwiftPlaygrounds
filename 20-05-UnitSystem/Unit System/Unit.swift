//
//  Unit.swift
//  Unit System
//
//  Created by Karsten Bruns on 10.05.20.
//  Copyright © 2020 Karsten Bruns. All rights reserved.
//

import Foundation


protocol UnitObject: AnyObject {
    var id: Int { get }
    var link: UnitLink { get }
}


protocol Unit: UnitObject, Identifiable {

    init(requirement: Requirement<Self>, link: UnitLink) throws

    func requirementsSatisfied(resolvedUnits: ResolvedUnits)

    func requirementsSatisfactionLost()
}


extension Unit {
    var id: Int {
        var hasher = Hasher()
        hasher.combine(String(describing: self))
        for child in Mirror(reflecting: self).children {
            switch child.value {
            case let id as HardUnitProperty:
                hasher.combine(id.hashValue)
            default:
                break
            }
        }
        return hasher.finalize()
    }
}


struct UnitRef: Hashable, Identifiable {
    let id: Int

    weak var object: UnitObject!

    private let requirementsSatisfiedHandler: (ResolvedUnits) -> Void
    private let requirementsSatisfactionLostHandler: () -> Void
    private let requirementsHandler: () -> Set<AnyRequirement>

    init<U: Unit>(_ unit: U) {
        self.object = unit
        self.id = unit.id

        self.requirementsSatisfiedHandler = { [unowned unit] resolvedUnits in
            unit.requirementsSatisfied(resolvedUnits: resolvedUnits)
        }

        self.requirementsSatisfactionLostHandler = { [unowned unit] in
            unit.requirementsSatisfactionLost()
        }

        self.requirementsHandler = { [unowned unit] in
            unit.requirements
        }
    }

    static func == (lhs: UnitRef, rhs: UnitRef) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    var requirements: Set<AnyRequirement> {
        requirementsHandler()
    }

    func requirementsSatisfied(resolvedUnits: ResolvedUnits) {
        requirementsSatisfiedHandler(resolvedUnits)
    }

    func requirementsSatisfactionLost() {
        requirementsSatisfactionLostHandler()
    }
}
