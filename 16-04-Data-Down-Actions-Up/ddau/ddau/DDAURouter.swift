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
    func call(dataReceiver: DataReceiver, receiptHandler: (DataReceipt) -> ())
}


public enum DataDirection {
    case handleOnMainQueue
    case handleOnBackgroundQueue
    case sendDown
    case stop
}



public enum DataReceipt {
    case handledDefinitely
    case sendDownToViewControllers(viewControllers: [ViewController])
    case sendDown
}



public protocol DataReceiver {
    static func directDataPackage(_ dataPackage: DataPackage) -> DataDirection
}



// MARK: Actions

public protocol ActionPackage { }



public enum ActionReceipt {
    case handledDefinitely
    case sendUp
}



public protocol ActionReceiver {
    func receiveActionPackage(_ actionPackage: ActionPackage) -> ActionReceipt
}



// MARK: - DataDown-/ActionsUp-Router -

private struct DDAURouter {
    
    static let sharedInstance = DDAURouter()
    let operationQueue: OperationQueue

    
    init() {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        self.operationQueue = operationQueue
    }
    
    
    static func sendDataPackageDown(_ dataPackage: DataPackage, viewControllers: [ViewController]) {
        let instance = DDAURouter.sharedInstance
        instance.operationQueue.addOperation() {
            instance.sendDataPackageDown(dataPackage, viewControllers: viewControllers)
        }
    }
    
    
    private func sendDataPackageDown(_ dataPackage: DataPackage, viewControllers: [ViewController]) {
    
        // Iterate through view conrollers
        for viewController in viewControllers {
            
            var viewControllersWhitelist: [ViewController]? = nil
            var sendDown = true

            if let receivingViewController = viewController as? DataReceiver {

                // Side effect-free call on background thread
                let dataDirection = type(of: receivingViewController).directDataPackage(dataPackage)
                
                switch dataDirection {
                case .handleOnMainQueue, .handleOnBackgroundQueue:

                    // Handling with potential side-effects
                    let determinSendDownStatus = DispatchGroup()
                    determinSendDownStatus.enter()

                    let callViewController = {
                        dataPackage.call(dataReceiver: receivingViewController, receiptHandler: { receipt in
                            switch receipt {
                            case .handledDefinitely :
                                sendDown = false
                            case .sendDownToViewControllers(let viewControllers) :
                                viewControllersWhitelist = viewControllers
                                sendDown = true
                            case .sendDown :
                                sendDown = true
                            }
                        })
                        determinSendDownStatus.leave()
                    }

                    if dataDirection == .handleOnMainQueue {
                        // Call on main thread
                        dispatchOnMainQueue(sync: true, code: callViewController)
                    } else {
                        // Call on this (background) thread
                        callViewController()
                    }
                    
                    _ = determinSendDownStatus.wait(timeout: DispatchTime.distantFuture)
                    
                case .sendDown:
                    sendDown = true
                case .stop:
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
    
    
    static func sendActionPackageUp(_ actionPackage: ActionPackage, viewController: ViewController) {
        let sharedRouter = DDAURouter.sharedInstance
        sharedRouter.operationQueue.addOperation() {
            sharedRouter.sendActionPackageUp(actionPackage, viewController: viewController)
        }
    }
    
    
    func sendActionPackageUp(_ actionPackage: ActionPackage, viewController: ViewController) {
        
        // Get possible parent instances as specific type
        func parentViewControllerAsReceiver() -> ActionReceiver? {
            return viewController.parent as? ActionReceiver
        }
        
        func appDelegateAsReceiver() -> ActionReceiver? {
            guard viewController == viewController.view.window?.rootViewController else { return nil }
            return UIApplication.shared.delegate as? ActionReceiver
        }
        
        func parentViewControllerAsRouter() -> ViewController? {
            return viewController.parent
        }
        
        // Hand over packages to parent handler
        var sendUp: Bool?
        if let parentActionReceiving = parentViewControllerAsReceiver() ?? appDelegateAsReceiver() {
            dispatchOnMainQueue(sync: true) {
                sendUp = parentActionReceiving.receiveActionPackage(actionPackage) == .sendUp
            }
        } else {
            sendUp = true
        }
        
        // Let parent send package up
        if let sendUp = sendUp, sendUp == true {
            if let parentDDAURouter = parentViewControllerAsRouter() {
                sendActionPackageUp(actionPackage, viewController: parentDDAURouter)
            }
        }
    }
}



// MARK: - Type Extensions -
// MARK: Data

extension ViewController {
    public func sendDataPackageDown(_ dataPackage: DataPackage) {
        DDAURouter.sendDataPackageDown(dataPackage, viewControllers: childViewControllers)
    }
}



// MARK: Actions

extension ApplicationDelegate {
    func sendDataPackageDown(rootViewController: ViewController, dataPackage: DataPackage) {
        DDAURouter.sendDataPackageDown(dataPackage, viewControllers: [rootViewController])
    }
}


extension ViewController {
    public func sendActionPackageUp(_ actionPackage: ActionPackage) {
        DDAURouter.sendActionPackageUp(actionPackage, viewController: self)
    }
}
