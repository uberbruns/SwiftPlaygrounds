//
//  FSM.swift
//  swiftFSM
//
//  Created by Karsten Bruns on 23.03.19.
//  Copyright © 2019 bruns.me. All rights reserved.
//

import Foundation


class FiniteStateMachine<FS: FSMState> {

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

class FSMObservationToken {

  fileprivate let uid: Int
  fileprivate var deinitialization: (() -> Void)?

  fileprivate init(uid: Int) {
    self.uid = uid
  }

  deinit {
    deinitialization?()
  }

  func retain(in tokenPool: FSMObservationTokenPool) {
    tokenPool.tokens.append(self)
  }
}


class FSMObservationTokenPool {
  fileprivate var tokens = [Any]()

  init() { }
}

extension FiniteStateMachine {

  typealias Observation = (FSMLifeCycleEvent<FS>) -> Void

  func addObserver(_ block: @escaping Observation) -> FSMObservationToken {
    let token = FSMObservationToken(uid: observerUIDs)
    token.deinitialization = { [weak self] in
      self?.observations.removeValue(forKey: token.uid)
    }
    observations[token.uid] = block
    observerUIDs += 1
    return token
  }
}
