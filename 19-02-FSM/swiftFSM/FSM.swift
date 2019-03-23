//
//  FSM.swift
//  swiftFSM
//
//  Created by Karsten Bruns on 23.03.19.
//  Copyright © 2019 bruns.me. All rights reserved.
//

import Foundation


class FiniteStateMachine<FS: FSMState>: ObservableFiniteStateMachine {

  typealias TransitionHandler = (FS.TransitionType, FS, FS) -> Void

  private var transitionHandlers = [TransitionHandler]()

  private var observerUIDs = 0
  private var observations = [Int: Observation]() {
    didSet {
      sortedObservations = observations.sorted(by: { $0.key < $1.key }).map({ $0.value })
    }
  }
  private var sortedObservations = [Observation]()

  private(set) var state: FS

  init(state: FS) {
    self.state = state
  }

  func can(_ transition: FS.TransitionType) -> Bool {
    do {
      _ = try transition.transformer()(state)
      return true
    } catch {
      return false
    }
  }

  func perform(_ transition: FS.TransitionType) throws {
    let newState = try transition.transformer()(state)
    let oldState = state

    sortedObservations.forEach { $0(.willTransition(from: oldState, to: newState)) }
    sortedObservations.forEach { $0(.willPerform(transition: transition)) }
    transitionHandlers.forEach { $0(transition, oldState, newState) }
    state = newState
    sortedObservations.forEach { $0(.didPerform(transition: transition)) }
    sortedObservations.forEach { $0(.didTransition(from: oldState, to: newState)) }
  }

  func addHandler(_ transitionHandler: @escaping TransitionHandler) {
    transitionHandlers.append(transitionHandler)
  }
}


// MARK: - Observability -

private protocol ObservableFiniteStateMachine: AnyObject{
  func removeObserver(_ token: FSMObservationToken)
}


class FSMObservationToken {

  private weak var stateMachine: ObservableFiniteStateMachine?
  let uid: Int

  fileprivate init(uid: Int, stateMachine: ObservableFiniteStateMachine) {
    self.uid = uid
  }

  deinit {
    stateMachine?.removeObserver(self)
  }

  func append(to array: inout [FSMObservationToken]) {
    array.append(self)
  }

  func retain(in array: inout [Any]) {
    array.append(self)
  }
}


extension FiniteStateMachine {

  typealias Observation = (FSMLifeCycleEvent<FS>) -> Void

  func addObserver(_ block: @escaping Observation) -> FSMObservationToken {
    let token = FSMObservationToken(uid: observerUIDs, stateMachine: self)
    observations[token.uid] = block
    observerUIDs += 1
    return token
  }

  fileprivate func removeObserver(_ token: FSMObservationToken) {
    observations.removeValue(forKey: token.uid)
  }
}
