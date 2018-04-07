//
//  NSConstraint+Extensions.swift
//  NSConstraintExtensions
//
//  Created by Karsten Bruns on 07.04.18.
//  Copyright © 2018 bruns.me. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    
    open static func toggleConstraints(_ constraints: [NSLayoutConstraint]) {
        
        var constraintsToActivate = [NSLayoutConstraint]()
        var constraintsToDeactivate = [NSLayoutConstraint]()
        
        for constraint in constraints {
            // Handle constraint for invisible views
            let viewIsHidden = (constraint.firstItem as? UIView)?.isInvisible == true
            if constraint.identifier?.starts(with: ".") == true {
                if viewIsHidden && !constraint.isActive {
                    constraintsToActivate.append(constraint)
                } else if !viewIsHidden && constraint.isActive {
                    constraintsToDeactivate.append(constraint)
                }
                continue
            }

            // Handle visibility dependent constraints
            if constraint.identifier?.starts(with: "~") == true {
                // `true` if one participating view is hidden
                let deactivateConstraint = [constraint.firstItem, constraint.secondItem]
                    .compactMap({ $0 as? UIView })
                    .contains(where: { $0.isInvisible })
                
                if deactivateConstraint && constraint.isActive {
                    constraintsToDeactivate.append(constraint)
                } else if !deactivateConstraint && !constraint.isActive {
                    constraintsToActivate.append(constraint)
                }
                continue
            }

            // Handle permanent active constraints
            if !constraint.isActive {
                constraintsToActivate.append(constraint)
            }
        }
        
        NSLayoutConstraint.activate(constraintsToActivate)
        NSLayoutConstraint.deactivate(constraintsToDeactivate)
    }
}


extension NSLayoutXAxisAnchor {
    func constraint(equalTo anchor: NSLayoutXAxisAnchor, identifier: String, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let newConstraint = constraint(equalTo: anchor)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        return newConstraint
    }
    
    func constraint(greaterThanOrEqualTo anchor: NSLayoutXAxisAnchor, identifier: String, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let newConstraint = constraint(greaterThanOrEqualTo: anchor)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        return newConstraint
    }
    
    func constraint(lessThanOrEqualTo anchor: NSLayoutXAxisAnchor, identifier: String, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let newConstraint = constraint(lessThanOrEqualTo: anchor)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        return newConstraint
    }
    
    func constraint(equalTo anchor: NSLayoutXAxisAnchor, constant c: CGFloat, identifier: String, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let newConstraint = constraint(equalTo: anchor, constant: c)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        return newConstraint
    }
    
    func constraint(greaterThanOrEqualTo anchor: NSLayoutXAxisAnchor, constant c: CGFloat, identifier: String, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let newConstraint = constraint(greaterThanOrEqualTo: anchor, constant: c)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        return newConstraint
    }
    
    func constraint(lessThanOrEqualTo anchor: NSLayoutXAxisAnchor, constant c: CGFloat, identifier: String, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let newConstraint = constraint(lessThanOrEqualTo: anchor, constant: c)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        return newConstraint
    }
    
    @available(iOS 11.0, *)
    open func constraintEqualToSystemSpacingAfter(_ anchor: NSLayoutXAxisAnchor, multiplier: CGFloat, identifier: String, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let newConstraint = constraintEqualToSystemSpacingAfter(anchor, multiplier: multiplier)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        return newConstraint
    }
    
    @available(iOS 11.0, *)
    open func constraintGreaterThanOrEqualToSystemSpacingAfter(_ anchor: NSLayoutXAxisAnchor, multiplier: CGFloat, identifier: String, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let newConstraint = constraintGreaterThanOrEqualToSystemSpacingAfter(anchor, multiplier: multiplier)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        return newConstraint
    }
    
    @available(iOS 11.0, *)
    open func constraintLessThanOrEqualToSystemSpacingAfter(_ anchor: NSLayoutXAxisAnchor, multiplier: CGFloat, identifier: String, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let newConstraint = constraintLessThanOrEqualToSystemSpacingAfter(anchor, multiplier: multiplier)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        return newConstraint
    }
}


extension NSLayoutYAxisAnchor {
    func constraint(equalTo anchor: NSLayoutYAxisAnchor, identifier: String, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let newConstraint = constraint(equalTo: anchor)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        return newConstraint
    }
    
    func constraint(greaterThanOrEqualTo anchor: NSLayoutYAxisAnchor, identifier: String, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let newConstraint = constraint(greaterThanOrEqualTo: anchor)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        return newConstraint
    }

    func constraint(lessThanOrEqualTo anchor: NSLayoutYAxisAnchor, identifier: String, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let newConstraint = constraint(lessThanOrEqualTo: anchor)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        return newConstraint
    }

    func constraint(equalTo anchor: NSLayoutYAxisAnchor, constant c: CGFloat, identifier: String, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let newConstraint = constraint(equalTo: anchor, constant: c)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        return newConstraint
    }

    func constraint(greaterThanOrEqualTo anchor: NSLayoutYAxisAnchor, constant c: CGFloat, identifier: String, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let newConstraint = constraint(greaterThanOrEqualTo: anchor, constant: c)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        return newConstraint
    }

    func constraint(lessThanOrEqualTo anchor: NSLayoutYAxisAnchor, constant c: CGFloat, identifier: String, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let newConstraint = constraint(lessThanOrEqualTo: anchor, constant: c)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        return newConstraint
    }
    
    @available(iOS 11.0, *)
    open func constraintEqualToSystemSpacingBelow(_ anchor: NSLayoutYAxisAnchor, multiplier: CGFloat, identifier: String, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let newConstraint = constraintEqualToSystemSpacingBelow(anchor, multiplier: multiplier)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        return newConstraint
    }
    
    @available(iOS 11.0, *)
    open func constraintGreaterThanOrEqualToSystemSpacingBelow(_ anchor: NSLayoutYAxisAnchor, multiplier: CGFloat, identifier: String, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let newConstraint = constraintGreaterThanOrEqualToSystemSpacingBelow(anchor, multiplier: multiplier)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        return newConstraint
    }
    
    @available(iOS 11.0, *)
    open func constraintLessThanOrEqualToSystemSpacingBelow(_ anchor: NSLayoutYAxisAnchor, multiplier: CGFloat, identifier: String, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let newConstraint = constraintLessThanOrEqualToSystemSpacingBelow(anchor, multiplier: multiplier)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        return newConstraint
    }
}


extension NSLayoutDimension {
    open func constraint(equalTo anchor: NSLayoutDimension, identifier: String, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let newConstraint = constraint(equalTo: anchor)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        return newConstraint
    }
    
    open func constraint(greaterThanOrEqualTo anchor: NSLayoutDimension, identifier: String, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let newConstraint = constraint(greaterThanOrEqualTo: anchor)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        return newConstraint
    }
    
    open func constraint(lessThanOrEqualTo anchor: NSLayoutDimension, identifier: String, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let newConstraint = constraint(lessThanOrEqualTo: anchor)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        return newConstraint
    }
    
    open func constraint(equalTo anchor: NSLayoutDimension, constant c: CGFloat, identifier: String, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let newConstraint = constraint(equalTo: anchor, constant: c)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        return newConstraint
    }
    
    open func constraint(greaterThanOrEqualTo anchor: NSLayoutDimension, constant c: CGFloat, identifier: String, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let newConstraint = constraint(greaterThanOrEqualTo: anchor, constant: c)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        return newConstraint
    }
    
    open func constraint(lessThanOrEqualTo anchor: NSLayoutDimension, constant c: CGFloat, identifier: String, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let newConstraint = constraint(lessThanOrEqualTo: anchor, constant: c)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        return newConstraint
    }

    open func constraint(equalToConstant c: CGFloat, identifier: String, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let newConstraint = constraint(equalToConstant: c)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        return newConstraint
    }
    
    open func constraint(greaterThanOrEqualToConstant c: CGFloat, identifier: String, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let newConstraint = constraint(greaterThanOrEqualToConstant: c)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        return newConstraint
    }
    
    open func constraint(lessThanOrEqualToConstant c: CGFloat, identifier: String, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let newConstraint = constraint(lessThanOrEqualToConstant: c)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        return newConstraint
    }
    
    open func constraint(equalTo anchor: NSLayoutDimension, multiplier m: CGFloat, identifier: String, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let newConstraint = constraint(equalTo: anchor, multiplier: m)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        return newConstraint
    }
    
    open func constraint(greaterThanOrEqualTo anchor: NSLayoutDimension, multiplier m: CGFloat, identifier: String, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let newConstraint = constraint(greaterThanOrEqualTo: anchor, multiplier: m)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        return newConstraint
    }
    
    open func constraint(lessThanOrEqualTo anchor: NSLayoutDimension, multiplier m: CGFloat, identifier: String, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let newConstraint = constraint(lessThanOrEqualTo: anchor, multiplier: m)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        return newConstraint
    }
    
    open func constraint(equalTo anchor: NSLayoutDimension, multiplier m: CGFloat, constant c: CGFloat, identifier: String, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let newConstraint = constraint(equalTo: anchor, multiplier: m)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        return newConstraint
    }
    
    open func constraint(greaterThanOrEqualTo anchor: NSLayoutDimension, multiplier m: CGFloat, constant c: CGFloat, identifier: String, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let newConstraint = constraint(greaterThanOrEqualTo: anchor, multiplier: m)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        return newConstraint
    }
    
    open func constraint(lessThanOrEqualTo anchor: NSLayoutDimension, multiplier m: CGFloat, constant c: CGFloat, identifier: String, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let newConstraint = constraint(lessThanOrEqualTo: anchor, multiplier: m, constant: c)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        return newConstraint
    }
}


private extension UIView {
    var isInvisible: Bool {
        return isHidden || alpha < 0.0001
    }
}
