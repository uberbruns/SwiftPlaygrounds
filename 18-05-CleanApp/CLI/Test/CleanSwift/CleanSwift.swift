//
//  main.swift
//  ProtocolCluster
//
//  Created by Karsten Bruns on 19.05.18.
//  Copyright © 2018 Karsten Bruns. All rights reserved.
//

import UIKit


// ===================================
// MARK: SCENE
// ===================================

protocol SceneProtocol {
  associatedtype RouterType: RouterProtocol
  func build(_ startRouting: (RouterType) -> Void)
}


// ===================================
// MARK: ROUTER
// ===================================

public enum RoutingOptions {
  case show(UIViewController)
  case present(UIViewController)
  case embed(UIViewController, UIView)
  case embedInWindow(UIWindow)
  case forceOnTop
}

protocol RouterProtocol: class where UserInterfaceType: UIViewController {
  associatedtype UserInterfaceType
  init(userInterface: UserInterfaceType)
  func start(options: RoutingOptions)
}


// ===================================
// MARK: USE CASES
// ===================================

protocol UseCaseProtocol { }


// ===================================
// MARK: INTERACTOR
// ===================================

protocol DataStoreProtocol { }

protocol BusinessLogicProtocol: class { }

protocol InteractorProtocol: DataStoreProtocol, BusinessLogicProtocol {
  associatedtype RouterType: RouterProtocol
  associatedtype PresenterType: PresenterProtocol
  init(router: RouterType, presenter: PresenterType)
}


// ===================================
// MARK: PRESENTER
// ===================================

protocol PresenterProtocol {
  associatedtype UserInterfaceType
  init(userInterface: UserInterfaceType)
}


// ===================================
// MARK: USER INTERFACE
// ===================================

protocol UserInterfaceProtocol: class { }