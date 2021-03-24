import UIKit


extension NSLayoutXAxisAnchor {
    func constraint(equalTo anchor: NSLayoutXAxisAnchor, multiplier m: CGFloat = 1, identifier: String? = nil, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        constraint(equalTo: anchor).with(multiplier: m, identifier: identifier, priority: priority).with(multiplier: m, identifier: identifier, priority: priority)
    }
    
    func constraint(greaterThanOrEqualTo anchor: NSLayoutXAxisAnchor, multiplier m: CGFloat = 1, identifier: String? = nil, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        constraint(greaterThanOrEqualTo: anchor).with(multiplier: m, identifier: identifier, priority: priority)
    }
    
    func constraint(lessThanOrEqualTo anchor: NSLayoutXAxisAnchor, multiplier m: CGFloat = 1, identifier: String? = nil, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        constraint(lessThanOrEqualTo: anchor).with(multiplier: m, identifier: identifier, priority: priority)
    }
    
    func constraint(equalTo anchor: NSLayoutXAxisAnchor, multiplier m: CGFloat = 1, constant c: CGFloat = 0, identifier: String? = nil, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        constraint(equalTo: anchor, constant: c).with(multiplier: m, identifier: identifier, priority: priority)
    }
    
    func constraint(greaterThanOrEqualTo anchor: NSLayoutXAxisAnchor, multiplier m: CGFloat = 1, constant c: CGFloat = 0, identifier: String? = nil, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        constraint(greaterThanOrEqualTo: anchor, constant: c).with(multiplier: m, identifier: identifier, priority: priority)
    }
    
    func constraint(lessThanOrEqualTo anchor: NSLayoutXAxisAnchor, multiplier m: CGFloat = 1, constant c: CGFloat = 0, identifier: String? = nil, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        constraint(lessThanOrEqualTo: anchor, constant: c).with(multiplier: m, identifier: identifier, priority: priority)
    }
}


extension NSLayoutYAxisAnchor {
    func constraint(equalTo anchor: NSLayoutYAxisAnchor, multiplier m: CGFloat = 1, identifier: String? = nil, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        constraint(equalTo: anchor).with(multiplier: m, identifier: identifier, priority: priority)
    }
    
    func constraint(greaterThanOrEqualTo anchor: NSLayoutYAxisAnchor, multiplier m: CGFloat = 1, identifier: String? = nil, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        constraint(greaterThanOrEqualTo: anchor).with(multiplier: m, identifier: identifier, priority: priority)
    }

    func constraint(lessThanOrEqualTo anchor: NSLayoutYAxisAnchor, multiplier m: CGFloat = 1, identifier: String? = nil, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        constraint(lessThanOrEqualTo: anchor).with(multiplier: m, identifier: identifier, priority: priority)
    }

    func constraint(equalTo anchor: NSLayoutYAxisAnchor, multiplier m: CGFloat = 1, constant c: CGFloat = 0, identifier: String? = nil, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        constraint(equalTo: anchor, constant: c).with(multiplier: m, identifier: identifier, priority: priority)
    }

    func constraint(greaterThanOrEqualTo anchor: NSLayoutYAxisAnchor, multiplier m: CGFloat = 1, constant c: CGFloat = 0, identifier: String? = nil, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        constraint(greaterThanOrEqualTo: anchor, constant: c).with(multiplier: m, identifier: identifier, priority: priority)
    }

    func constraint(lessThanOrEqualTo anchor: NSLayoutYAxisAnchor, multiplier m: CGFloat = 1, constant c: CGFloat = 0, identifier: String? = nil, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        constraint(lessThanOrEqualTo: anchor, constant: c).with(multiplier: m, identifier: identifier, priority: priority)
    }
}


extension NSLayoutDimension {
    open func constraint(equalTo anchor: NSLayoutDimension, multiplier m: CGFloat = 1, identifier: String? = nil, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        constraint(equalTo: anchor).with(multiplier: m, identifier: identifier, priority: priority)
    }
    
    open func constraint(greaterThanOrEqualTo anchor: NSLayoutDimension, multiplier m: CGFloat = 1, identifier: String? = nil, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        constraint(greaterThanOrEqualTo: anchor).with(multiplier: m, identifier: identifier, priority: priority)
    }
    
    open func constraint(lessThanOrEqualTo anchor: NSLayoutDimension, multiplier m: CGFloat = 1, identifier: String? = nil, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        constraint(lessThanOrEqualTo: anchor).with(multiplier: m, identifier: identifier, priority: priority)
    }
    
    open func constraint(equalTo anchor: NSLayoutDimension, multiplier m: CGFloat = 1, constant c: CGFloat = 0, identifier: String? = nil, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        constraint(equalTo: anchor, constant: c).with(multiplier: m, identifier: identifier, priority: priority)
    }
    
    open func constraint(greaterThanOrEqualTo anchor: NSLayoutDimension, multiplier m: CGFloat = 1, constant c: CGFloat = 0, identifier: String? = nil, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        constraint(greaterThanOrEqualTo: anchor, constant: c).with(multiplier: m, identifier: identifier, priority: priority)
    }
    
    open func constraint(lessThanOrEqualTo anchor: NSLayoutDimension, multiplier m: CGFloat = 1, constant c: CGFloat = 0, identifier: String? = nil, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        constraint(lessThanOrEqualTo: anchor, constant: c).with(multiplier: m, identifier: identifier, priority: priority)
    }

    open func constraint(equalToConstant c: CGFloat, multiplier m: CGFloat = 1, identifier: String? = nil, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        constraint(equalToConstant: c).with(multiplier: m, identifier: identifier, priority: priority)
    }
    
    open func constraint(greaterThanOrEqualToConstant c: CGFloat, multiplier m: CGFloat = 1, identifier: String? = nil, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        constraint(greaterThanOrEqualToConstant: c).with(multiplier: m, identifier: identifier, priority: priority)
    }
    
    open func constraint(lessThanOrEqualToConstant c: CGFloat, multiplier m: CGFloat = 1, identifier: String? = nil, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        constraint(lessThanOrEqualToConstant: c).with(multiplier: m, identifier: identifier, priority: priority)
    }
}


private extension NSLayoutConstraint {
    func with(multiplier: CGFloat, identifier: String?, priority: UILayoutPriority) -> NSLayoutConstraint {
        let constraint: NSLayoutConstraint

        if multiplier == 1 {
            constraint = self
        } else {
            constraint = NSLayoutConstraint(
                item: firstItem as Any,
                attribute: firstAttribute,
                relatedBy: relation,
                toItem: secondItem,
                attribute: secondAttribute,
                multiplier: multiplier,
                constant: constant
            )
        }
        constraint.identifier = identifier
        constraint.priority = priority

        return constraint
    }
}
