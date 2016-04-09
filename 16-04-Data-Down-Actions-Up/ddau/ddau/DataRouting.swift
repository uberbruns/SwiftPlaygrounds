//
//  DataRouter.swift
//  ddau
//
//  Created by Karsten Bruns on 08/04/16.
//  Copyright © 2016 Karsten Bruns. All rights reserved.
//

import UIKit


protocol DataPackage { }


struct TestDataPackage : DataPackage {
    let name: String
}


enum DataDirection {
    case HandleHere
    case SendDown
    case Stop
}


enum DataReceipt {
    case HandledDefinitely
    case SendDownToViewControllers(viewControllers: [UIViewController])
    case SendDown
}



protocol DataDownRouter {
    func sendDataPackageDown(dataPackage: DataPackage)
}



protocol DataReceiver {
    static func directDataPackage(dataPackage: DataPackage) -> DataDirection
    func receiveDataPackage(dataPackage: DataPackage) -> DataReceipt
}


private struct DataDownRouterHelper {
    
    static func sendDataPackageDown(dataPackage: DataPackage, viewControllers: [UIViewController]) {
        dispatchInBackground {
            _sendDataPackageDown(dataPackage, viewControllers: viewControllers)
        }
    }
    
    static func _sendDataPackageDown(dataPackage: DataPackage, viewControllers: [UIViewController]) {
        
        // Iterate through view conrollers
        for viewController in viewControllers {
            
            var lowerViewControllersWhitelist: [UIViewController]? = nil
            var sendDown = true

            if let receivingViewController = viewController as? DataReceiver {
                // Allow data package
                // Side effect-free call on background thread
                let dataDirection = receivingViewController.dynamicType.directDataPackage(dataPackage)
                switch dataDirection {
                case .HandleHere:
                    // Call on main thread with potential side effects
                    dispatchOnMainThread(true) {
                        switch receivingViewController.receiveDataPackage(dataPackage) {
                        case .HandledDefinitely :
                            sendDown = false
                        case .SendDownToViewControllers(let viewControllers) :
                            lowerViewControllersWhitelist = viewControllers
                            sendDown = true
                        case .SendDown :
                            sendDown = true
                        }
                    }
                case .SendDown:
                    sendDown = true
                case .Stop:
                    sendDown = false
                }
            }
            
            // Hand down
            let viewControllers: [UIViewController]
            if let lowerViewControllersWhitelist = lowerViewControllersWhitelist {
                viewControllers = viewController.childViewControllers.filter({ lowerViewControllersWhitelist.contains($0) })
            } else {
                viewControllers = viewController.childViewControllers
            }
            
            if sendDown {
                _sendDataPackageDown(dataPackage, viewControllers: viewControllers)
            }
        }
    }
}



extension UIViewController : DataDownRouter {
    func sendDataPackageDown(dataPackage: DataPackage) {
        DataDownRouterHelper.sendDataPackageDown(dataPackage, viewControllers: childViewControllers)
    }
}



extension AppDelegate : DataDownRouter {
    func sendDataPackageDown(dataPackage: DataPackage) {
        guard let rootViewController = window?.rootViewController else { return }
        DataDownRouterHelper.sendDataPackageDown(dataPackage, viewControllers: [rootViewController])
    }
}