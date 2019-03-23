//
//  FSM+Model.swift
//  swiftFSM
//
//  Created by Karsten Bruns on 23.03.19.
//  Copyright © 2019 bruns.me. All rights reserved.
//

import Foundation


// MARK: Protocols

protocol FSMState {
  associatedtype TransitionType: FSMTransition where TransitionType.FiniteStateType == Self
}


extension FSMTransition where FiniteStateType: Hashable {
  func transformer(from source: FiniteStateType, to destination: FiniteStateType) -> (FiniteStateType) throws -> FiniteStateType {
    return { current in
      switch current {
      case source:
        return destination
      default:
        throw FSMError.illegalTransition
      }
    }
  }
}


protocol FSMTransition {
  associatedtype FiniteStateType: FSMState
  func transformer() -> (FiniteStateType) throws -> FiniteStateType
}


// MARK: Types

enum FSMError: Error {
  case illegalTransition
}

enum FSMLifeCycleEvent<FS: FSMState> {
  case willTransition(from: FS, to: FS)
  case didTransition(from: FS, to: FS)
  case willPerform(transition: FS.TransitionType)
  case didPerform(transition: FS.TransitionType)
}
