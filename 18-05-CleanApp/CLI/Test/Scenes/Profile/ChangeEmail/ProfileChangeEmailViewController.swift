//
//  ProfileChangeEmailViewController.swift
//  Neptune
//
//  Created by Karsten Bruns on 22.5.2018.
//  Copyright © 2018 MOIA GmbH. All rights reserved.
//

import UIKit
import CleanSwift

class ProfileChangeEmailViewController: UIViewController, ProfileChangeEmailUserInterfaceProtocol {
  var interactor: ProfileChangeEmailBusinessLogicProtocol?

  override func viewDidLoad() {
    super.viewDidLoad()
    interactor?.doViewDidLoad(with: ProfileChangeEmailUseCase.ViewDidLoad.Request())
  }
}