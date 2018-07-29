//
//  main.swift
//  ProtocolCluster
//
//  Created by Karsten Bruns on 19.05.18.
//  Copyright © 2018 Karsten Bruns. All rights reserved.
//

import Foundation

class UIViewController { }


// MARK: USER INTERFACE

protocol UserInterfaceProtocol {
  static func instantiate() -> Self
}

protocol MapUserInterfaceProtocol: UserInterfaceProtocol {
  var interactor: MapBusinessLogicProtocol? { get set }
}

class MapViewController: UIViewController, MapUserInterfaceProtocol {
  static func instantiate() -> Self { fatalError() }
  var interactor: MapBusinessLogicProtocol?
}



// MARK: ROUTER

protocol RouterProtocol {
  associatedtype UserInterfaceType
}

protocol MapRouterProtocol: RouterProtocol where UserInterfaceType: MapUserInterfaceProtocol {
  var dataStore: MapDataStoreProtocol? { get set }
}

class MapRouter<UI: MapUserInterfaceProtocol>: MapRouterProtocol {
  var dataStore: MapDataStoreProtocol?
  typealias UserInterfaceType = UI
}



// MARK: SCENE

protocol SceneProtocol {
  associatedtype RouterType: RouterProtocol
  func build() -> RouterType
}

class MapScene: SceneProtocol {
  typealias RouterType = MapRouter<MapViewController>

  func build() -> RouterType {
    let userInterface = MapViewController()
    let router = MapRouter<MapViewController>()
    let presenter = MapPresenter(userInterface: userInterface)
    let interactor = MapInteractor(router: router, presenter: presenter)
    userInterface.interactor = interactor
    router.dataStore = interactor
    return router
  }
}


// MARK: PRESENTER

protocol PresenterProtocol {
  associatedtype UserInterfaceType
  init(userInterface: UserInterfaceType)
}

protocol MapPresenterProtocol: PresenterProtocol where UserInterfaceType: MapUserInterfaceProtocol { }

class MapPresenter<UI: MapUserInterfaceProtocol>: MapPresenterProtocol {
  typealias UserInterfaceType = UI
  required init(userInterface: UI) { fatalError() }
}


// MARK: INTERACTOR

protocol DataStoreProtocol { }

protocol MapDataStoreProtocol: DataStoreProtocol { }


protocol BusinessLogicProtocol { }

protocol MapBusinessLogicProtocol: BusinessLogicProtocol { }


protocol InteractorProtocol: DataStoreProtocol, BusinessLogicProtocol {
  associatedtype RouterType: RouterProtocol
  associatedtype PresenterType: PresenterProtocol
  init(router: RouterType, presenter: PresenterType)
}

protocol MapInteractorProtocol: InteractorProtocol, MapDataStoreProtocol, MapBusinessLogicProtocol where RouterType: MapRouterProtocol, PresenterType: MapPresenterProtocol { }

class MapInteractor<RO: MapRouterProtocol, PR: MapPresenterProtocol>: MapInteractorProtocol {
  typealias RouterType = RO
  typealias PresenterType = PR

  required init(router: RO, presenter: PR) {
    fatalError()
  }
}


















