//
//  ActionRouter.swift
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



public protocol ActionUpRouter {
    func sendActionPackageUp(actionPackage: ActionPackage)
}



public protocol ActionReceiver {
    func receiveActionPackage(actionPackage: ActionPackage) -> ActionReceipt
}



extension UIViewController {

    public func sendActionPackageUp(actionPackage: ActionPackage) {
        
        // Get possible parent instances as specific type
        func parentViewControllerAsReceiver() -> ActionReceiver? {
            return self.parentViewController as? ActionReceiver
        }
        
        func appDelegateAsReceiver() -> ActionReceiver? {
            guard self == self.view.window?.rootViewController else { return nil }
            return UIApplication.sharedApplication().delegate as? ActionReceiver
        }
        
        func parentViewControllerAsRouter() -> UIViewController? {
            return self.parentViewController
        }
        
        // Hand over packages to parent handler
        let sendUp: Bool
        if let parentActionReceiver = parentViewControllerAsReceiver() ?? appDelegateAsReceiver() {
            sendUp = parentActionReceiver.receiveActionPackage(actionPackage) == .SendUp
        } else {
            sendUp = true
        }
        
        // Let parent send package up
        if let parentActionRouter = parentViewControllerAsRouter() {
            if sendUp {
                parentActionRouter.sendActionPackageUp(actionPackage)
            }
        }
    }
}