//
//  ProfileChangeEmailInteractor.swift
//  Neptune
//
//  Created by Karsten Bruns on 22.5.2018.
//  Copyright © 2018 MOIA GmbH. All rights reserved.
//

import UIKit
import CleanSwift

class ProfileChangeEmailInteractor<RO: ProfileChangeEmailRouterProtocol, PR: ProfileChangeEmailPresenterProtocol>: ProfileChangeEmailInteractorProtocol {

  private let presenter: PR
  private let router: RO

  required init(router: RO, presenter: PR) {
    self.presenter = presenter
    self.router = router
  }
}