//
//  ProfileChangeEmailRouter.swift
//  Neptune
//
//  Created by Karsten Bruns on 22.5.2018.
//  Copyright © 2018 MOIA GmbH. All rights reserved.
//

import UIKit
import CleanSwift

protocol ProfileChangeEmailRouterProtocol: RouterProtocol where UserInterfaceType: ProfileChangeEmailUserInterfaceProtocol {
  var dataStore: ProfileChangeEmailDataStoreProtocol? { get set }
  func routeToProfileChangeEmailView()
}

class ProfileChangeEmailRouter<UI: ProfileChangeEmailUserInterfaceProtocol & UIViewController>: ProfileChangeEmailRouterProtocol {
  weak var dataStore: ProfileChangeEmailDataStoreProtocol?
  private weak var userInterface: UI!

  required init(userInterface: UI) {
    self.userInterface = userInterface
  }

  func start(options: RoutingOptions) {
    switch options {
    case .embedInWindow(let window):
      let navigationController = UINavigationController(rootViewController: userInterface)
      window.rootViewController = navigationController
      window.makeKeyAndVisible()
    case .show(let currentViewController):
      currentViewController.navigationController?.pushViewController(userInterface, animated: true)
    default:
      break
    }
  }
}