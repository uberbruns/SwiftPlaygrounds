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

// -----------------------------------

class MapScene: SceneProtocol {

  private let userInterface = MapViewController()

  func build(_ startRouting: (MapRouter<MapViewController>) -> Void) {
    let router = MapRouter<MapViewController>(userInterface: userInterface)
    let presenter = MapPresenter(userInterface: userInterface)
    let interactor = MapInteractor(router: router, presenter: presenter)
    userInterface.interactor = interactor
    router.dataStore = interactor
    startRouting(router)
  }

  deinit {
    print(#function, self)
  }
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

// -----------------------------------

protocol MapRouterProtocol: RouterProtocol where UserInterfaceType: MapUserInterfaceProtocol {
  var dataStore: MapDataStoreProtocol? { get set }
  func routeToMapView()
}

class MapRouter<UI: MapUserInterfaceProtocol & UIViewController>: MapRouterProtocol {
  weak var dataStore: MapDataStoreProtocol?
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

  func routeToMapView() {
    MapScene().build { router in
      router.start(options: .show(userInterface))
    }
  }

  deinit {
    print(#function, self)
  }
}


// ===================================
// MARK: USE CASES
// ===================================

protocol UseCaseProtocol { }

// -----------------------------------

enum MapUseCase: UseCaseProtocol {
  enum ViewDidLoad {
    struct Request { }
    struct Response { }
    struct ViewModel {
      var title: String
    }
  }
  enum Interaction {
    struct Request { }
    struct Response { }
    struct ViewModel { }
  }
  enum ChangeOrigin {
    struct Request { }
    struct Response { }
    struct ViewModel { }
  }
  enum ChangeDestination {
    struct Request { }
    struct Response { }
    struct ViewModel { }
  }
}


// ===================================
// MARK: INTERACTOR
// ===================================

protocol DataStoreProtocol { }

protocol BusinessLogicProtocol: class { }

protocol InteractorProtocol: DataStoreProtocol, BusinessLogicProtocol {
  associatedtype RouterType: RouterProtocol
  associatedtype PresenterType: PresenterProtocol
}

// -----------------------------------

protocol MapDataStoreProtocol: class, DataStoreProtocol { }

protocol MapBusinessLogicProtocol: BusinessLogicProtocol {
  func doViewDidLoad(with request: MapUseCase.ViewDidLoad.Request)
  func doInteraction(with request: MapUseCase.Interaction.Request)
}

protocol MapInteractorProtocol: InteractorProtocol, MapDataStoreProtocol, MapBusinessLogicProtocol where RouterType: MapRouterProtocol, PresenterType: MapPresenterProtocol { }

class MapInteractor<RO: MapRouterProtocol, PR: MapPresenterProtocol>: MapInteractorProtocol {

  private let presenter: PR
  private let router: RO

  required init(router: RO, presenter: PR) {
    self.presenter = presenter
    self.router = router
  }

  func doViewDidLoad(with request: MapUseCase.ViewDidLoad.Request) {
    presenter.presentViewDidLoad(with: MapUseCase.ViewDidLoad.Response())
  }

  func doInteraction(with request: MapUseCase.Interaction.Request) {
    router.routeToMapView()
  }

  deinit {
    print(#function, self)
  }
}


// ===================================
// MARK: PRESENTER
// ===================================

protocol PresenterProtocol {
  associatedtype UserInterfaceType
  init(userInterface: UserInterfaceType)
}

// -----------------------------------

protocol MapPresenterProtocol: PresenterProtocol where UserInterfaceType: MapUserInterfaceProtocol {
  func presentViewDidLoad(with response: MapUseCase.ViewDidLoad.Response)
}

class MapPresenter<UI: MapUserInterfaceProtocol>: MapPresenterProtocol {
  private weak var userInterface: UI!

  required init(userInterface: UI) {
    self.userInterface = userInterface
  }

  func presentViewDidLoad(with response: MapUseCase.ViewDidLoad.Response) {
    userInterface.displayViewDidLoad(with: .init(title: "Hello"))
  }

  deinit {
    print(#function, self)
  }
}


// ===================================
// MARK: USER INTERFACE
// ===================================

protocol UserInterfaceProtocol: class { }

// -----------------------------------

protocol MapUserInterfaceProtocol: UserInterfaceProtocol {
  var interactor: MapBusinessLogicProtocol! { get set }
  func displayViewDidLoad(with viewModel: MapUseCase.ViewDidLoad.ViewModel)
}

class MapViewController: UIViewController, MapUserInterfaceProtocol {
  var interactor: MapBusinessLogicProtocol!

  override func viewDidLoad() {
    super.viewDidLoad()
    interactor.doViewDidLoad(with: MapUseCase.ViewDidLoad.Request())
    view.backgroundColor = .white
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapGesture)))
  }

  func displayViewDidLoad(with viewModel: MapUseCase.ViewDidLoad.ViewModel) {
    title = viewModel.title
  }

  @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
    interactor.doInteraction(with: MapUseCase.Interaction.Request())
  }

  deinit {
    print(#function, self)
  }
}
