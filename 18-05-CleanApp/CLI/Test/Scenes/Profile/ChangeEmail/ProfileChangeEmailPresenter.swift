//
//  ProfileChangeEmailPresenter.swift
//  Neptune
//
//  Created by Karsten Bruns on 22.5.2018.
//  Copyright © 2018 MOIA GmbH. All rights reserved.
//

import UIKit
import CleanSwift

class ProfileChangeEmailPresenter<UI: ProfileChangeEmailUserInterfaceProtocol>: ProfileChangeEmailPresenterProtocol {
  private weak var userInterface: UI!

  required init(userInterface: UI) {
    self.userInterface = userInterface
  }
}