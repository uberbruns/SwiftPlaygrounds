//
//  UnitLink.swift
//  Unit System
//
//  Created by Karsten Bruns on 21.05.20.
//  Copyright © 2020 Karsten Bruns. All rights reserved.
//

import Foundation


class UnitLink {
    fileprivate var requirements = Set<AnyRequirement>()
    private weak var manager: UnitManager?

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
    var requirements: Set<AnyRequirement> {
        link.requirements
    }

    func addRequirement<U>(_ requirement: Requirement<U>) {
        link.addRequirement(requirement)
    }

    func addRequirement<U>(_ requirement: Requirement<U>, _ requirementRefinements: Requirement<U>...) {
        link.addRequirement(requirement, requirementRefinements)
    }
}
