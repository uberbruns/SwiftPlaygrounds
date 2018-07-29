//
//  ProfileChangeEmailUseCase.swift
//  Neptune
//
//  Created by Karsten Bruns on 22.5.2018.
//  Copyright © 2018 MOIA GmbH. All rights reserved.
//

import UIKit
import CleanSwift

enum ProfileChangeEmailUseCase: UseCaseProtocol {
  enum ViewDidLoad {
    struct Request { }
    struct Response { }
    struct ViewModel { }
  }
  enum SubmitEmail {
    struct Request { }
  }
}