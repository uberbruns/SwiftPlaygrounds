// Generated using Sourcery 0.11.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT



// MARK: Interactor

protocol ProfileChangeEmailDataStoreProtocol: class, DataStoreProtocol { }

protocol ProfileChangeEmailBusinessLogicProtocol: BusinessLogicProtocol {
  func doViewDidLoad(with request: ProfileChangeEmailUseCase.ViewDidLoad.Request)
  func doSubmitEmail(with request: ProfileChangeEmailUseCase.SubmitEmail.Request)
}

protocol ProfileChangeEmailInteractorProtocol: InteractorProtocol, MapDataStoreProtocol, ProfileChangeEmailBusinessLogicProtocol where RouterType: ProfileChangeEmailRouterProtocol, PresenterType: ProfileChangeEmailPresenterProtocol { }

// MARK: Presenter

protocol ProfileChangeEmailPresenterProtocol: PresenterProtocol where UserInterfaceType: ProfileChangeEmailUserInterfaceProtocol {
  func presentViewDidLoad(with response: ProfileChangeEmailUseCase.ViewDidLoad.Response)
}

// MARK: User Interface

protocol ProfileChangeEmailUserInterfaceProtocol: UserInterfaceProtocol {
  var interactor: ProfileChangeEmailBusinessLogicProtocol? { get set }

  func displayViewDidLoad(with viewModel: ProfileChangeEmailUseCase.ViewDidLoad.ViewModel)
}

