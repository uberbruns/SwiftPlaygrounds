//
//  ProfileChangeEmailScene.swift
//  Neptune
//
//  Created by Karsten Bruns on 22.5.2018.
//  Copyright © 2018 MOIA GmbH. All rights reserved.
//

import UIKit
import CleanSwift

class ProfileChangeEmailScene: SceneProtocol {

  private let userInterface = ProfileChangeEmailViewController()

  func build(_ startRouting: (ProfileChangeEmailRouter<ProfileChangeEmailViewController>) -> Void) {
    let router = ProfileChangeEmailRouter<ProfileChangeEmailViewController>(userInterface: userInterface)
    let presenter = ProfileChangeEmailPresenter(userInterface: userInterface)
    let interactor = ProfileChangeEmailInteractor(router: router, presenter: presenter)
    userInterface.interactor = interactor
    router.dataStore = interactor
    startRouting(router)
  }
}