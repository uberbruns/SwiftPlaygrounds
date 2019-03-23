//
//  FSM+ConvenienceExtensions.swift
//  swiftFSM
//
//  Created by Karsten Bruns on 23.03.19.
//  Copyright © 2019 bruns.me. All rights reserved.
//

import Foundation


// MARK: Info

extension FiniteStateMachine where FS: CaseIterable {
  var allState: [FS] {
    return Array(FS.allCases)
  }
}


extension FiniteStateMachine where FS.TransitionType: CaseIterable {
  var allTransitions: [FS.TransitionType] {
    return Array(FS.TransitionType.allCases)
  }

  var transitions: [FS.TransitionType] {
    return FS.TransitionType.allCases.filter { can($0) }
  }
}


// MARK: Observability

extension FiniteStateMachine where FS.TransitionType: Hashable {

  func handle(_ aTransition: FS.TransitionType, work: @escaping () -> Void) {
    addHandler { (transition, _, _) in
      switch transition {
      case aTransition:
        work()
      default:
        break
      }
    }
  }

  func will(perform transition: FS.TransitionType, work: @escaping () -> Void) -> FSMObservationToken {
    return addObserver { (event) in
      switch event {
      case .willPerform(transition: transition):
        work()
      default:
        break
      }
    }
  }

  func did(perform transition: FS.TransitionType, work: @escaping () -> Void) -> FSMObservationToken {
    return addObserver { (event) in
      switch event {
      case .didPerform(transition: transition):
        work()
      default:
        break
      }
    }
  }
}

extension FiniteStateMachine where FS: Hashable {
  func will(leave state: FS, work: @escaping () -> Void) -> FSMObservationToken {
    return addObserver { (event) in
      switch event {
      case .willTransition(from: state, to: _):
        work()
      default:
        break
      }
    }
  }

  func did(leave state: FS, work: @escaping () -> Void) -> FSMObservationToken {
    return addObserver { (event) in
      switch event {
      case .didTransition(from: state, to: _):
        work()
      default:
        break
      }
    }
  }

  func will(enter state: FS, work: @escaping () -> Void) -> FSMObservationToken {
    return addObserver { (event) in
      switch event {
      case .willTransition(from: _, to: state):
        work()
      default:
        break
      }
    }
  }

  func did(enter state: FS, work: @escaping () -> Void) -> FSMObservationToken {
    return addObserver { (event) in
      switch event {
      case .didTransition(from: _, to: state):
        work()
      default:
        break
      }
    }
  }
}
