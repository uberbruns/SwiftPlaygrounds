// Copyright © 2018 Karsten Bruns

import UIKit

class KeyboardLayoutGuide: UILayoutGuide {
    private(set) var heightConstraint: NSLayoutConstraint!
    weak var delegate: KeyboardLayoutGuideDelegate?

    override init() {
        super.init()
        heightConstraint = heightAnchor.constraint(equalToConstant: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillChangeFrameNotification), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func handleKeyboardWillChangeFrameNotification(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        let animationCurveNumber = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveAsInt = animationCurveNumber?.intValue
        let animationCurve = UIView.AnimationCurve(rawValue: animationCurveAsInt ?? UIView.AnimationCurve.easeInOut.rawValue)
        let animationOptions = UIView.AnimationOptions().byInserting(animationCurve ?? UIView.AnimationCurve.easeInOut)
        let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0

        if let owningView = owningView, owningView.window != nil {
            let frameInWindow = owningView.convert(owningView.bounds, to: nil)
            let intersection = frameInWindow.intersection(keyboardFrame)
            let oldHeight = self.heightConstraint.constant
            let newHeight = intersection.height
            delegate?.keyboardLayoutGuide(self, willChangeFrom: oldHeight, to: newHeight, animated: true)
            UIView.animate(withDuration: animationDuration, delay: 0, options: animationOptions, animations: {
                self.heightConstraint.constant = intersection.height
                owningView.setNeedsLayout()
                owningView.layoutIfNeeded()
                self.delegate?.keyboardLayoutGuide(self, isChangingFrom: oldHeight, to: newHeight, animated: true)
            }, completion: nil)
        } else {
            let oldHeight = self.heightConstraint.constant
            let newHeight = keyboardFrame.height
            delegate?.keyboardLayoutGuide(self, willChangeFrom: oldHeight, to: newHeight, animated: false)
            heightConstraint.constant = newHeight
            delegate?.keyboardLayoutGuide(self, isChangingFrom: oldHeight, to: newHeight, animated: false)
        }
    }
}


protocol KeyboardLayoutGuideDelegate: AnyObject {
    func keyboardLayoutGuide(_ keyboardLayoutGuide: KeyboardLayoutGuide, willChangeFrom heightBefore: CGFloat, to heightAfter: CGFloat, animated: Bool)
    func keyboardLayoutGuide(_ keyboardLayoutGuide: KeyboardLayoutGuide, isChangingFrom heightBefore: CGFloat, to heightAfter: CGFloat, animated: Bool)
}


private extension UIView.AnimationOptions {
    func byInserting(_ curve: UIView.AnimationCurve) -> UIView.AnimationOptions {
        var new = self
        switch curve.rawValue {
        case UIView.AnimationCurve.easeIn.rawValue:
            new.insert(.curveEaseIn)
        case UIView.AnimationCurve.easeOut.rawValue:
            new.insert(.curveEaseOut)
        case UIView.AnimationCurve.easeInOut.rawValue:
            new.insert(.curveEaseInOut)
        case UIView.AnimationCurve.linear.rawValue:
            new.insert(.curveLinear)
        default:
            new.insert(.curveEaseIn)
        }
        return new
    }
}
