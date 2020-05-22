//
//  Unit.swift
//  Unit System
//
//  Created by Karsten Bruns on 10.05.20.
//  Copyright © 2020 Karsten Bruns. All rights reserved.
//

import Foundation


protocol Unit: AnyObject, Identifiable {
    var link: UnitLink { get }

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
            case let id as UnitIdentifier:
                hasher.combine(id.rawId)
            default:
                break
            }
        }
        return hasher.finalize()
    }
}


struct AnyUnit: Hashable, Identifiable {
    let id: Int
    let base: Any

    private let requirementsSatisfiedHandler: (Any) -> Void
    private let requirementsSatisfactionLostHandler: () -> Void
    private let requirementsHandler: () -> Set<AnyRequirement>

    init<U: Unit>(_ base: U) {
        self.base = base
        self.id = base.id

        self.requirementsSatisfiedHandler = { anyResolvedUnits in
            guard let resolvedUnits = anyResolvedUnits as? ResolvedUnits else { fatalError() }
            base.requirementsSatisfied(resolvedUnits: resolvedUnits)
        }

        self.requirementsSatisfactionLostHandler = {
            base.requirementsSatisfactionLost()
        }

        self.requirementsHandler = {
            base.requirements
        }
    }

    static func == (lhs: AnyUnit, rhs: AnyUnit) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    var requirements: Set<AnyRequirement> {
        requirementsHandler()
    }

    func requirementsSatisfied(resolvedUnits: Any) {
        requirementsSatisfiedHandler(resolvedUnits)
    }

    func requirementsSatisfactionLost() {
        requirementsSatisfactionLostHandler()
    }
}
