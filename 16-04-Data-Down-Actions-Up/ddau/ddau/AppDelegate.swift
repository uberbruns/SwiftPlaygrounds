//
//  AppDelegate.swift
//  ddau
//
//  Created by Karsten Bruns on 07/04/16.
//  Copyright © 2016 Karsten Bruns. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate, ActionReceiver {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        splitViewController.delegate = self
        return true
    }

    
    func receiveActionPackage(actionPackage: ActionPackage) -> ActionReceipt {
        print(self, "Received action", actionPackage)
        switch actionPackage {
        case let action as MasterDataRequestAction :
            action.receiptHandler(receipt: MasterDataRequestReceipt(transactionId: 123))
            window?.rootViewController.map {
                sendDataPackageDown(rootViewController: $0, dataPackage: MasterData(name: "Data from app delegate"))
            }
        default :
            window?.rootViewController.map {
                sendDataPackageDown(rootViewController: $0, dataPackage: DetailData(name: "Data from app delegate"))
            }
        }
        return ActionReceipt.HandledDefinitely
    }


    // MARK: - Split view

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
        if topAsDetailController.detailItem == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }

}