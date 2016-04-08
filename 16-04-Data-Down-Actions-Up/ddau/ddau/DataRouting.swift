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



enum DataReceipt {
    case HandledDefinitely
    case SendDown
}



protocol DataDownRouter {
    func sendDataPackageDown(dataPackage: DataPackage)
    func sendDataPackagesDown(dataPackages: [DataPackage])
}



protocol DataReceiver {
    func receiveDataPackage(dataPackage: DataPackage) -> DataReceipt
}



extension DataDownRouter {
    func sendDataPackageDown(dataPackage: DataPackage) {
        sendDataPackagesDown([dataPackage])
    }
}



private struct DataDownRouterHelper {
    static func sendDataPackagesDown(dataPackages: [DataPackage], viewControllers: [UIViewController]) {
        for viewController in viewControllers {
            let remainingPackages: [DataPackage]
            if let receiver = viewController as? DataReceiver {
                remainingPackages = dataPackages.filter { dataPackage in
                    let sendDown = receiver.receiveDataPackage(dataPackage) == .SendDown
                    return sendDown
                }
            } else {
                remainingPackages = dataPackages
            }
            viewController.sendDataPackagesDown(remainingPackages)
        }
    }
}



extension UIViewController : DataDownRouter {
    func sendDataPackagesDown(dataPackages: [DataPackage]) {
        DataDownRouterHelper.sendDataPackagesDown(dataPackages, viewControllers: childViewControllers)
    }
}



extension AppDelegate : DataDownRouter {
    func sendDataPackagesDown(dataPackages: [DataPackage]) {
        guard let childViewControllers = window?.rootViewController?.childViewControllers else { return }
        DataDownRouterHelper.sendDataPackagesDown(dataPackages, viewControllers: childViewControllers)
    }
}