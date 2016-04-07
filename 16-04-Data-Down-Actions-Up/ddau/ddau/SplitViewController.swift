//
//  TabBarController.swift
//  ddau
//
//  Created by Karsten Bruns on 07/04/16.
//  Copyright © 2016 Karsten Bruns. All rights reserved.
//

import UIKit

class SplitViewController : UISplitViewController, ActionCatcher {

    func filterActionPackages(actionPackages: [ActionPackage]) -> [ActionPackage] {
        print(actionPackages, "received by", self)
        return actionPackages
    }
    
}
