//
//  ActionRouter.swift
//  ddau
//
//  Created by Karsten Bruns on 07/04/16.
//  Copyright © 2016 Karsten Bruns. All rights reserved.
//

import UIKit


struct ActionPackage {
    let name: String
}



enum ActionReceipt {
    case HandledDefinitely
    case SendUp
}



protocol ActionUpRouter {
    func sendActionPackageUp(actionPackage: ActionPackage)
    func sendActionPackagesUp(actionPackages: [ActionPackage])
}



protocol ActionReceiver {
    func receiveActionPackage(actionPackage: ActionPackage) -> ActionReceipt
}



extension ActionUpRouter {
    
    func sendActionPackageUp(actionPackage: ActionPackage) {
        sendActionPackagesUp([actionPackage])
    }
}



extension UIViewController : ActionUpRouter {

    func sendActionPackagesUp(actionPackages: [ActionPackage]) {
        
        // Get possible parent instances as specific type
        func parentViewControllerAsReceiver() -> ActionReceiver? {
            return self.parentViewController as? ActionReceiver
        }
        
        func appDelegateAsReceiver() -> ActionReceiver? {
            guard self == self.view.window?.rootViewController else { return nil }
            return UIApplication.sharedApplication().delegate as? ActionReceiver
        }
        
        func parentViewControllerAsRouter() -> ActionUpRouter? {
            return self.parentViewController
        }
        
        // Hand over packages to parent handler
        let remainingPackages: [ActionPackage]
        if let parentActionReceiver = parentViewControllerAsReceiver() ?? appDelegateAsReceiver() {
            remainingPackages = actionPackages.filter { package in
                let sendUp = parentActionReceiver.receiveActionPackage(package) == .SendUp
                return sendUp
            }
        } else {
            remainingPackages = actionPackages
        }
        
        // Let parent send package up
        if let parentActionRouter = parentViewControllerAsRouter() {
            if remainingPackages.count > 0 {
                parentActionRouter.sendActionPackagesUp(remainingPackages)
            }
        }
    }
}