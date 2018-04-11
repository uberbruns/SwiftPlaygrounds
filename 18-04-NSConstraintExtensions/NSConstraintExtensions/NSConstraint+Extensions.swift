//
//  NSConstraint+Extensions.swift
//  NSConstraintExtensions
//
//  Created by Karsten Bruns on 07.04.18.
//  Copyright © 2018 bruns.me. All rights reserved.
//

import ObjectiveC
import UIKit

extension NSLayoutConstraint {

    /// Activates and deactivates constraints based on the state of the
    /// participating views and or the naming of the identifier.
    ///
    /// - Starting the identifier with a dot "." activates the constraint only if its first view is hidden.
    /// - Starting the identifier with a "~" deactivates a constraint if one of the two views is hidden.
    /// - Starting the identifier with a "?" uses the delegate to determine if the constraint should be activated.
    ///
    /// - Parameters:
    ///   - constraints: A list of constraints that should be automatically activated or deactivated.
    ///   - delegate: An optional reference to a class, that decides if a constraint starting with "?" should be activated or not.
    open static func evaluateConstraints(_ constraints: [NSLayoutConstraint], delegate: LayoutConstraintDelegate? = nil) {
        var constraintsToActivate = [NSLayoutConstraint]()
        var constraintsToDeactivate = [NSLayoutConstraint]()
        
        for constraint in constraints {
            // Handle constraint for invisible views
            let viewIsHidden = (constraint.firstItem as? UIView)?.isInvisible == true
            if constraint.activationRule == .firstInvisible {
                if viewIsHidden && !constraint.isActive {
                    constraintsToActivate.append(constraint)
                } else if !viewIsHidden && constraint.isActive {
                    constraintsToDeactivate.append(constraint)
                }
                continue
            }

            // Handle visibility dependent constraints
            if constraint.activationRule == .bothVisible {
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

            // Handle delegate managed constraints
            if constraint.activationRule == .delegate, let delegate = delegate {
                let shouldBeActive = delegate.shouldActivateConstraint(constraint)
                if shouldBeActive && !constraint.isActive {
                    constraintsToActivate.append(constraint)
                } else if !shouldBeActive && constraint.isActive {
                    constraintsToDeactivate.append(constraint)
                }
                continue
            }

            // Handle always active constraints
            if constraint.activationRule == .always, !constraint.isActive {
                constraintsToActivate.append(constraint)
            }
        }
        
        NSLayoutConstraint.activate(constraintsToActivate)
        NSLayoutConstraint.deactivate(constraintsToDeactivate)
    }
}


public protocol LayoutConstraintDelegate {
    func shouldActivateConstraint(_ constraint: NSLayoutConstraint) -> Bool
}


extension NSLayoutXAxisAnchor {
    func constraint(equalTo anchor: NSLayoutXAxisAnchor, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(equalTo: anchor)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    func constraint(greaterThanOrEqualTo anchor: NSLayoutXAxisAnchor, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(greaterThanOrEqualTo: anchor)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    func constraint(lessThanOrEqualTo anchor: NSLayoutXAxisAnchor, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(lessThanOrEqualTo: anchor)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    func constraint(equalTo anchor: NSLayoutXAxisAnchor, constant c: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(equalTo: anchor, constant: c)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    func constraint(greaterThanOrEqualTo anchor: NSLayoutXAxisAnchor, constant c: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(greaterThanOrEqualTo: anchor, constant: c)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    func constraint(lessThanOrEqualTo anchor: NSLayoutXAxisAnchor, constant c: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(lessThanOrEqualTo: anchor, constant: c)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    @available(iOS 11.0, *)
    open func constraintEqualToSystemSpacingAfter(_ anchor: NSLayoutXAxisAnchor, multiplier: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraintEqualToSystemSpacingAfter(anchor, multiplier: multiplier)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    @available(iOS 11.0, *)
    open func constraintGreaterThanOrEqualToSystemSpacingAfter(_ anchor: NSLayoutXAxisAnchor, multiplier: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraintGreaterThanOrEqualToSystemSpacingAfter(anchor, multiplier: multiplier)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    @available(iOS 11.0, *)
    open func constraintLessThanOrEqualToSystemSpacingAfter(_ anchor: NSLayoutXAxisAnchor, multiplier: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraintLessThanOrEqualToSystemSpacingAfter(anchor, multiplier: multiplier)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
}


extension NSLayoutYAxisAnchor {
    func constraint(equalTo anchor: NSLayoutYAxisAnchor, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(equalTo: anchor)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    func constraint(greaterThanOrEqualTo anchor: NSLayoutYAxisAnchor, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(greaterThanOrEqualTo: anchor)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }

    func constraint(lessThanOrEqualTo anchor: NSLayoutYAxisAnchor, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(lessThanOrEqualTo: anchor)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }

    func constraint(equalTo anchor: NSLayoutYAxisAnchor, constant c: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(equalTo: anchor, constant: c)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }

    func constraint(greaterThanOrEqualTo anchor: NSLayoutYAxisAnchor, constant c: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(greaterThanOrEqualTo: anchor, constant: c)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }

    func constraint(lessThanOrEqualTo anchor: NSLayoutYAxisAnchor, constant c: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(lessThanOrEqualTo: anchor, constant: c)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    @available(iOS 11.0, *)
    open func constraintEqualToSystemSpacingBelow(_ anchor: NSLayoutYAxisAnchor, multiplier: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraintEqualToSystemSpacingBelow(anchor, multiplier: multiplier)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    @available(iOS 11.0, *)
    open func constraintGreaterThanOrEqualToSystemSpacingBelow(_ anchor: NSLayoutYAxisAnchor, multiplier: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraintGreaterThanOrEqualToSystemSpacingBelow(anchor, multiplier: multiplier)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    @available(iOS 11.0, *)
    open func constraintLessThanOrEqualToSystemSpacingBelow(_ anchor: NSLayoutYAxisAnchor, multiplier: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraintLessThanOrEqualToSystemSpacingBelow(anchor, multiplier: multiplier)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
}


extension NSLayoutDimension {
    open func constraint(equalTo anchor: NSLayoutDimension, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(equalTo: anchor)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    open func constraint(greaterThanOrEqualTo anchor: NSLayoutDimension, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(greaterThanOrEqualTo: anchor)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    open func constraint(lessThanOrEqualTo anchor: NSLayoutDimension, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(lessThanOrEqualTo: anchor)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    open func constraint(equalTo anchor: NSLayoutDimension, constant c: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(equalTo: anchor, constant: c)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    open func constraint(greaterThanOrEqualTo anchor: NSLayoutDimension, constant c: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(greaterThanOrEqualTo: anchor, constant: c)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    open func constraint(lessThanOrEqualTo anchor: NSLayoutDimension, constant c: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(lessThanOrEqualTo: anchor, constant: c)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }

    open func constraint(equalToConstant c: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(equalToConstant: c)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    open func constraint(greaterThanOrEqualToConstant c: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(greaterThanOrEqualToConstant: c)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    open func constraint(lessThanOrEqualToConstant c: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(lessThanOrEqualToConstant: c)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    open func constraint(equalTo anchor: NSLayoutDimension, multiplier m: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(equalTo: anchor, multiplier: m)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    open func constraint(greaterThanOrEqualTo anchor: NSLayoutDimension, multiplier m: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(greaterThanOrEqualTo: anchor, multiplier: m)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    open func constraint(lessThanOrEqualTo anchor: NSLayoutDimension, multiplier m: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(lessThanOrEqualTo: anchor, multiplier: m)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    open func constraint(equalTo anchor: NSLayoutDimension, multiplier m: CGFloat, constant c: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(equalTo: anchor, multiplier: m)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    open func constraint(greaterThanOrEqualTo anchor: NSLayoutDimension, multiplier m: CGFloat, constant c: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(greaterThanOrEqualTo: anchor, multiplier: m)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    open func constraint(lessThanOrEqualTo anchor: NSLayoutDimension, multiplier m: CGFloat, constant c: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(lessThanOrEqualTo: anchor, multiplier: m, constant: c)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
}


private extension UIView {
    var isInvisible: Bool {
        // TODO: ancestors
        return isHidden || alpha <= 0
    }
}


extension NSObject {
    func setAssociatedValue<T>(_ value: T, forKey associativeKey: UnsafeRawPointer, policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
        objc_setAssociatedObject(self, associativeKey, value,  policy)
    }
    
    func associatedValue<T>(forKey associativeKey: UnsafeRawPointer) -> T? {
        let value = objc_getAssociatedObject(self, associativeKey)
        return value as? T
    }
}


public enum ConstraintActivationRule {
    case manual
    case always
    case bothVisible
    case firstInvisible
    case delegate
}


extension NSLayoutConstraint {
    private struct AssociatedKeys {
        static var activationRule = "activationRule"
    }
    
    var activationRule: ConstraintActivationRule {
        get {
            return associatedValue(forKey: &AssociatedKeys.activationRule) ?? .always
        }
        set {
            setAssociatedValue(newValue, forKey: &AssociatedKeys.activationRule)
        }
    }
}
