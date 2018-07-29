//
//  main.swift
//  ProtocolCluster
//
//  Created by Karsten Bruns on 19.05.18.
//  Copyright © 2018 Karsten Bruns. All rights reserved.
//

import Foundation

// Router

class MapRouter<DS: MapDataStoreProtocol, UI: MapUserInterfaceProtocol>: MapRouterProtocol {

  var dataStore: DS?

  required init(userInterface: UI) { }
}



// Interactor

class MapInteractor<RO: MapRouterProtocol, PR: MapPresenterProtocol>: MapInteractorProtocol {
  required init(router: RO, presenter: PR) {
  }

  func someMapDataStoreFunc() {

  }
}



// Presenter

class MapPresenter<UI: MapUserInterfaceProtocol>: MapPresenterProtocol {
  var userInterface: UI

  required init(userInterface: UI) {
    self.userInterface = userInterface
  }
}


// User Interface

class MapViewController<BL: MapBusinessLogicProtocol>: UIViewController, MapUserInterfaceProtocol {

  static func instantiate() -> Self {
    fatalError()
  }

  var interactor: BL?

  func displayLocation() { }
}


// User Interface

class MapScene<IN: MapInteractorProtocol>: SceneProtocol where
  IN.RouterType.DataStoreType == IN,
  IN.PresenterType.UserInterfaceType == IN.RouterType.UserInterfaceType {
  
  typealias InteractorType = IN


  func build() -> IN.RouterType {
    let userInterface = MapViewController<IN>.instantiate()
    let router = IN.RouterType.init(userInterface: userInterface)
    /*
     let userInterface = UserInterfaceType.instantiate()
     let router = RouterType.init(userInterface: userInterface)
     let presenter = PresenterType.init(userInterface: userInterface)
     let interactor = InteractorType.init(router: router, presenter: presenter)
     userInterface.interactor = interactor
     router.dataStore = interactor
     return router
     */

    /// let userInterface = RO.
    fatalError()
  }
}

