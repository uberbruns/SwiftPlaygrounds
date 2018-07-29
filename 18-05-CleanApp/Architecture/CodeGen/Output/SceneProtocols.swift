// Generated using Sourcery 0.11.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT



// MARK: ----------------------------
// MARK: BoardingPass
// MARK: ----------------------------

// MARK: Interactor

protocol BoardingPassDataStoreProtocol: class, DataStoreProtocol { }

protocol BoardingPassBusinessLogicProtocol: BusinessLogicProtocol {
  func doViewDidLoad(with request: BoardingPassUseCase.ViewDidLoad.Request)
  func doCancelation(with request: BoardingPassUseCase.Cancelation.Request)
}

protocol BoardingPassInteractorProtocol: InteractorProtocol, MapDataStoreProtocol, BoardingPassBusinessLogicProtocol where RouterType: BoardingPassRouterProtocol, PresenterType: BoardingPassPresenterProtocol { }

// MARK: Presenter

protocol BoardingPassPresenterProtocol: PresenterProtocol where UserInterfaceType: BoardingPassUserInterfaceProtocol {
  func presentViewDidLoad(with response: BoardingPassUseCase.ViewDidLoad.Response)
  func presentCancelation(with response: BoardingPassUseCase.Cancelation.Response)
}

// MARK: User Interface

protocol BoardingPassUserInterfaceProtocol: UserInterfaceProtocol {
  var interactor: BoardingPassBusinessLogicProtocol? { get set }

  func displayViewDidLoad(with viewModel: BoardingPassUseCase.ViewDidLoad.ViewModel)
  func displayCancelation(with viewModel: BoardingPassUseCase.Cancelation.ViewModel)
}


// MARK: ----------------------------
// MARK: Map
// MARK: ----------------------------

// MARK: Interactor

protocol MapDataStoreProtocol: class, DataStoreProtocol { }

protocol MapBusinessLogicProtocol: BusinessLogicProtocol {
  func doViewDidLoad(with request: MapUseCase.ViewDidLoad.Request)
  func doInteraction(with request: MapUseCase.Interaction.Request)
  func doChangeOrigin(with request: MapUseCase.ChangeOrigin.Request)
  func doChangeDestination(with request: MapUseCase.ChangeDestination.Request)
}

protocol MapInteractorProtocol: InteractorProtocol, MapDataStoreProtocol, MapBusinessLogicProtocol where RouterType: MapRouterProtocol, PresenterType: MapPresenterProtocol { }

// MARK: Presenter

protocol MapPresenterProtocol: PresenterProtocol where UserInterfaceType: MapUserInterfaceProtocol {
  func presentViewDidLoad(with response: MapUseCase.ViewDidLoad.Response)
  func presentInteraction(with response: MapUseCase.Interaction.Response)
  func presentChangeOrigin(with response: MapUseCase.ChangeOrigin.Response)
  func presentChangeDestination(with response: MapUseCase.ChangeDestination.Response)
}

// MARK: User Interface

protocol MapUserInterfaceProtocol: UserInterfaceProtocol {
  var interactor: MapBusinessLogicProtocol? { get set }

  func displayViewDidLoad(with viewModel: MapUseCase.ViewDidLoad.ViewModel)
  func displayInteraction(with viewModel: MapUseCase.Interaction.ViewModel)
  func displayChangeOrigin(with viewModel: MapUseCase.ChangeOrigin.ViewModel)
  func displayChangeDestination(with viewModel: MapUseCase.ChangeDestination.ViewModel)
}


