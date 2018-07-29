//
//  main.swift
//  ProtocolCluster
//
//  Created by Karsten Bruns on 19.05.18.
//  Copyright © 2018 Karsten Bruns. All rights reserved.
//

import Foundation

class UIViewController { }


// Router

protocol RouterProtocol {
  associatedtype DataStoreType: DataStoreProtocol
  associatedtype UserInterfaceType: UserInterfaceProtocol

  var dataStore: DataStoreType? { get set }
  init(userInterface: UserInterfaceType)
}

protocol MapRouterProtocol: RouterProtocol where DataStoreType: MapDataStoreProtocol, UserInterfaceType: MapUserInterfaceProtocol { }



// Interactor / Business Logic

protocol DataStoreProtocol { }

protocol MapDataStoreProtocol: DataStoreProtocol {
  func someMapDataStoreFunc()
}


// Interactor / Business Logic

protocol BusinessLogicProtocol { }

protocol MapBusinessLogicProtocol: BusinessLogicProtocol { }


// Interactor

protocol InteractorProtocol: DataStoreProtocol, BusinessLogicProtocol {
  associatedtype RouterType: RouterProtocol
  associatedtype PresenterType: PresenterProtocol
  init(router: RouterType, presenter: PresenterType)
}

protocol MapInteractorProtocol: InteractorProtocol, MapDataStoreProtocol, MapBusinessLogicProtocol where RouterType: MapRouterProtocol, PresenterType: MapPresenterProtocol { }


// Presenter

protocol PresenterProtocol {
  associatedtype UserInterfaceType: UserInterfaceProtocol
  init(userInterface: UserInterfaceType)
}

protocol MapPresenterProtocol: PresenterProtocol where UserInterfaceType: MapUserInterfaceProtocol { }


// User Interface

protocol UserInterfaceProtocol {
  associatedtype BusinessLogicType: BusinessLogicProtocol
  static func instantiate() -> Self
  var interactor: BusinessLogicType? { get set }
}

protocol MapUserInterfaceProtocol: UserInterfaceProtocol where BusinessLogicType: MapBusinessLogicProtocol {
  func displayLocation()
}


// Scene

protocol SceneProtocol {
  associatedtype InteractorType: InteractorProtocol where
  InteractorType.RouterType.DataStoreType == InteractorType,
  InteractorType.PresenterType.UserInterfaceType == InteractorType.RouterType.UserInterfaceType

  func build() -> InteractorType.RouterType
}
