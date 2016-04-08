//
//  TabBarController.swift
//  ddau
//
//  Created by Karsten Bruns on 07/04/16.
//  Copyright © 2016 Karsten Bruns. All rights reserved.
//

import UIKit

class SplitViewController : UISplitViewController, ActionReceiver {

    func receiveActionPackage(actionPackage: ActionPackage) -> ActionReceipt {
        print(actionPackage, "received by", self)
        sendActionPackageUp(TestActionPackage(name: "Such Wow"))
        sendDataPackageDown(TestDataPackage(name: "Foo Fooooo"))
        return .HandledDefinitely
    }
    
}