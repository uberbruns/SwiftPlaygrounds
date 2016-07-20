//
//  DataRouter.swift
//  ddau
//
//  Created by Karsten Bruns on 08/04/16.
//  Copyright © 2016 Karsten Bruns. All rights reserved.
//


#if os(iOS)
    import UIKit
    public typealias ViewController = UIViewController
    public typealias ApplicationDelegate = UIApplicationDelegate
#else
    import AppKit
    public typealias ViewController = NSViewController
    public typealias ApplicationDelegate = NSApplicationDelegate
#endif



// MARK: - Types -
// MARK: Data

public protocol DataPackage {
    func call(dataReceiver dataReceiver: DataReceiver, receiptHandler: (DataReceipt) -> ())
}


public enum DataDirection {
    case HandleOnMainQueue
    case HandleOnBackgroundQueue
    case SendDown
    case Stop
}



public enum DataReceipt {
    case HandledDefinitely
    case SendDownToViewControllers(viewControllers: [ViewController])
    case SendDown
}



public protocol DataReceiver {
    static func directDataPackage(dataPackage: DataPackage) -> DataDirection
}



// MARK: Actions

public protocol ActionPackage { }



public enum ActionReceipt {
    case HandledDefinitely
    case SendUp
}



public protocol ActionReceiver {
    func receiveActionPackage(actionPackage: ActionPackage) -> ActionReceipt
}



// MARK: - DataDown-/ActionsUp-Router -

private struct DDAURouter {
    
    static let sharedInstance = DDAURouter()
    let operationQueue: NSOperationQueue

    
    init() {
        let operationQueue = NSOperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        self.operationQueue = operationQueue
    }
    
    
    static func sendDataPackageDown(dataPackage: DataPackage, viewControllers: [ViewController]) {
        let instance = DDAURouter.sharedInstance
        instance.operationQueue.addOperationWithBlock() {
            instance.sendDataPackageDown(dataPackage, viewControllers: viewControllers)
        }
    }
    
    
    private func sendDataPackageDown(dataPackage: DataPackage, viewControllers: [ViewController]) {
    
        // Iterate through view conrollers
        for viewController in viewControllers {
            
            var viewControllersWhitelist: [ViewController]? = nil
            var sendDown = true

            if let receivingViewController = viewController as? DataReceiver {

                // Side effect-free call on background thread
                let dataDirection = receivingViewController.dynamicType.directDataPackage(dataPackage)
                
                switch dataDirection {
                case .HandleOnMainQueue, .HandleOnBackgroundQueue:

                    // Handling with potential side-effects
                    let determinSendDownStatus = dispatch_group_create()
                    dispatch_group_enter(determinSendDownStatus)

                    let callViewController = {
                        dataPackage.call(dataReceiver: receivingViewController, receiptHandler: { receipt in
                            switch receipt {
                            case .HandledDefinitely :
                                sendDown = false
                            case .SendDownToViewControllers(let viewControllers) :
                                viewControllersWhitelist = viewControllers
                                sendDown = true
                            case .SendDown :
                                sendDown = true
                            }
                        })
                        dispatch_group_leave(determinSendDownStatus)
                    }

                    if dataDirection == .HandleOnMainQueue {
                        // Call on main thread
                        dispatchOnMainQueue(sync: true, code: callViewController)
                    } else {
                        // Call on this (background) thread
                        callViewController()
                    }
                    
                    dispatch_group_wait(determinSendDownStatus, DISPATCH_TIME_FOREVER)
                    
                case .SendDown:
                    sendDown = true
                case .Stop:
                    sendDown = false
                }
            }
            
            // Hand data down
            let viewControllers: [ViewController]
            if let viewControllersWhitelist = viewControllersWhitelist {
                viewControllers = viewController.childViewControllers.filter({ viewControllersWhitelist.contains($0) })
            } else {
                viewControllers = viewController.childViewControllers
            }
            
            if sendDown {
                sendDataPackageDown(dataPackage, viewControllers: viewControllers)
            }
        }
    }
    
    
    static func sendActionPackageUp(actionPackage: ActionPackage, viewController: ViewController) {
        let sharedRouter = DDAURouter.sharedInstance
        sharedRouter.operationQueue.addOperationWithBlock() {
            sharedRouter.sendActionPackageUp(actionPackage, viewController: viewController)
        }
    }
    
    
    func sendActionPackageUp(actionPackage: ActionPackage, viewController: ViewController) {
        
        // Get possible parent instances as specific type
        func parentViewControllerAsReceiver() -> ActionReceiver? {
            return viewController.parentViewController as? ActionReceiver
        }
        
        func appDelegateAsReceiver() -> ActionReceiver? {
            guard viewController == viewController.view.window?.rootViewController else { return nil }
            return UIApplication.sharedApplication().delegate as? ActionReceiver
        }
        
        func parentViewControllerAsRouter() -> ViewController? {
            return viewController.parentViewController
        }
        
        // Hand over packages to parent handler
        var sendUp: Bool?
        if let parentActionReceiving = parentViewControllerAsReceiver() ?? appDelegateAsReceiver() {
            dispatchOnMainQueue(sync: true) {
                sendUp = parentActionReceiving.receiveActionPackage(actionPackage) == .SendUp
            }
        } else {
            sendUp = true
        }
        
        // Let parent send package up
        if let sendUp = sendUp where sendUp == true {
            if let parentDDAURouter = parentViewControllerAsRouter() {
                sendActionPackageUp(actionPackage, viewController: parentDDAURouter)
            }
        }
    }
}



// MARK: - Type Extensions -
// MARK: Data

extension ViewController {
    public func sendDataPackageDown(dataPackage: DataPackage) {
        DDAURouter.sendDataPackageDown(dataPackage, viewControllers: childViewControllers)
    }
}



// MARK: Actions

extension ApplicationDelegate {
    func sendDataPackageDown(rootViewController rootViewController: ViewController, dataPackage: DataPackage) {
        DDAURouter.sendDataPackageDown(dataPackage, viewControllers: [rootViewController])
    }
}


extension ViewController {
    public func sendActionPackageUp(actionPackage: ActionPackage) {
        DDAURouter.sendActionPackageUp(actionPackage, viewController: self)
    }
}