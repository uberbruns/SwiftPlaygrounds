//
//  ActionSender.swift
//  ddau
//
//  Created by Karsten Bruns on 07/04/16.
//  Copyright © 2016 Karsten Bruns. All rights reserved.
//

import UIKit


public protocol ActionPackage { }


public enum ActionReceipt {
    case HandledDefinitely
    case SendUp
}



public protocol ActionReceiving {
    func receiveActionPackage(actionPackage: ActionPackage) -> ActionReceipt
}



private struct ActionSender {
    
    static func sendActionPackageUp(actionPackage: ActionPackage, viewController: UIViewController) {
        dispatchInBackground {
            _sendActionPackageUp(actionPackage, viewController: viewController)
        }
    }

    
    static func _sendActionPackageUp(actionPackage: ActionPackage, viewController: UIViewController) {
        
        // Get possible parent instances as specific type
        func parentViewControllerAsReceiver() -> ActionReceiving? {
            return viewController.parentViewController as? ActionReceiving
        }
        
        func appDelegateAsReceiver() -> ActionReceiving? {
            guard viewController == viewController.view.window?.rootViewController else { return nil }
            return UIApplication.sharedApplication().delegate as? ActionReceiving
        }
        
        func parentViewControllerAsRouter() -> UIViewController? {
            return viewController.parentViewController
        }
        
        // Hand over packages to parent handler
        var sendUp: Bool?
        if let parentActionReceiving = parentViewControllerAsReceiver() ?? appDelegateAsReceiver() {
            dispatchOnMainThread(true) {
                sendUp = parentActionReceiving.receiveActionPackage(actionPackage) == .SendUp
            }
        } else {
            sendUp = true
        }
        
        // Let parent send package up
        if let sendUp = sendUp where sendUp == true {
            if let parentActionSender = parentViewControllerAsRouter() {
                _sendActionPackageUp(actionPackage, viewController: parentActionSender)
            }
        }
    }
}


extension UIViewController {
    public func sendActionPackageUp(actionPackage: ActionPackage) {
        ActionSender.sendActionPackageUp(actionPackage, viewController: self)
    }
}