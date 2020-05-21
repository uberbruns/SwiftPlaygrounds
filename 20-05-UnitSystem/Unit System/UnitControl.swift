//
//  UnitControl.swift
//  Unit System
//
//  Created by Karsten Bruns on 21.05.20.
//  Copyright © 2020 Karsten Bruns. All rights reserved.
//

import Foundation


class UnitControl {
    private(set) var requirements = Set<AnyRequirement>()
    weak var manager: UnitManager?

    init(manager: UnitManager) {
        self.manager = manager
    }

    fileprivate func addRequirement<U>(_ requirement: Requirement<U>) {
        requirements.insert(AnyRequirement(requirement))
        manager?.setNeedsUpdate()
    }

    fileprivate func addRequirement<U>(_ requirement: Requirement<U>, _ requirementRefinements: [Requirement<U>]) {
        var combinedRequirement = requirement
        for requirementRefinement in requirementRefinements {
            combinedRequirement = combinedRequirement.union(requirementRefinement)
        }
        requirements.insert(AnyRequirement(combinedRequirement))
        manager?.setNeedsUpdate()
    }
}



extension Unit {
    func addRequirement<U>(_ requirement: Requirement<U>) {
        control.addRequirement(requirement)
    }

    func addRequirement<U>(_ requirement: Requirement<U>, _ requirementRefinements: Requirement<U>...) {
        control.addRequirement(requirement, requirementRefinements)
    }
}
