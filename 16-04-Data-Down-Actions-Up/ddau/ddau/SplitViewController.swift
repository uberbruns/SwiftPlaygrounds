//
//  TabBarController.swift
//  ddau
//
//  Created by Karsten Bruns on 07/04/16.
//  Copyright © 2016 Karsten Bruns. All rights reserved.
//

import UIKit

class SplitViewController : UISplitViewController, ActionReceiver, DataReceiver {

    static func directDataPackage(dataPackage: DataPackage) -> DataDirection {
        return .HandleHere
    }
    
    
    func receiveActionPackage(actionPackage: ActionPackage) -> ActionReceipt {
        print(self, "Received action", actionPackage)
        sendActionPackageUp(MasterAction(name: "Action from split view controller"))
        return .SendUp
    }
    
    
    func receiveDataPackage(dataPackage: DataPackage) -> DataReceipt {
        var specificViewControllers = [UIViewController]()
        
        if dataPackage is MasterData {
            specificViewControllers.append(viewControllers[0])
        }
        
        if dataPackage is DetailData {
            specificViewControllers.append(viewControllers[1])
        }
        
        if specificViewControllers.count > 0 {
            return .SendDownToViewControllers(viewControllers: specificViewControllers)
        }
        
        return .SendDown
    }
}