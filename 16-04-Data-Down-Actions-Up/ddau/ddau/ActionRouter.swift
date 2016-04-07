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


protocol ActionRouter {
    func sendActionPackageUpwards(actionPackage: ActionPackage)
    func sendActionPackagesUpwards(actionPackages: [ActionPackage])
}


protocol ActionCatcher {
    func filterActionPackages(actionPackages: [ActionPackage]) -> [ActionPackage]
}



extension ActionRouter {

    func sendActionPackageUpwards(actionPackage: ActionPackage) {
        sendActionPackagesUpwards([actionPackage])
    }

    
    func sendActionPackagesUpwards(actionPackages: [ActionPackage]) {
        
        func getParentViewControllerAsCatcher() -> ActionCatcher? {
            guard let viewController = self as? UIViewController else {
                return nil
            }
            return viewController.parentViewController as? ActionCatcher
        }
        
        
        func getAppDelegateAsCatcher() -> ActionCatcher? {
            guard let viewController = self as? UIViewController where viewController == viewController.view.window?.rootViewController else {
                return nil
            }
            return UIApplication.sharedApplication().delegate as? ActionCatcher
        }

        
        func getParentViewControllerAsRouter() -> ActionRouter? {
            guard let viewController = self as? UIViewController else {
                return nil
            }
            return viewController.parentViewController as? ActionRouter
        }
        

        let filteredPackages: [ActionPackage]
        if let parentActionCatcher = getParentViewControllerAsCatcher() ?? getAppDelegateAsCatcher() {
            filteredPackages = parentActionCatcher.filterActionPackages(actionPackages)
        } else {
            filteredPackages = actionPackages
        }
        
        if let parentActionRouter = getParentViewControllerAsRouter() {
            if filteredPackages.count > 0 {
                parentActionRouter.sendActionPackagesUpwards(filteredPackages)
            }
        }
    }
}


extension UIViewController : ActionRouter { }