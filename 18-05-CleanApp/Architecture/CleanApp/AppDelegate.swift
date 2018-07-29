//
//  AppDelegate.swift
//  CleanApp
//
//  Created by Karsten Bruns on 20.05.18.
//  Copyright © 2018 Karsten Bruns. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    MapScene().build { router in
      let window = UIWindow()
      router.start(options: .embedInWindow(window))
      self.window = window
    }
    return true
  }
}

