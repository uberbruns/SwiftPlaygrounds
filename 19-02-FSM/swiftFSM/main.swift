//
//  main.swift
//  swiftFSM
//
//  Created by Karsten Bruns on 24.02.19.
//  Copyright © 2019 bruns.me. All rights reserved.
//

import Foundation


enum Trip: FSMState, Hashable {
  typealias TransitionType = Transition

  case booking(destination: String)
  case waiting
  case traveling
  case arrived
}


extension Trip {
  enum Transition: FSMTransition {
    case ordering
    case entering
    case exiting

    func transformer() -> (Trip) throws -> Trip {
      switch self {
      case .entering:
        return transformer(from: .waiting, to: .traveling)

      case .exiting:
        return transformer(from: .traveling, to: .arrived)

      case .ordering:
        return { source in
          switch source {
          case .booking:
            return .waiting
          default:
            throw FSMError.illegalTransition
          }
        }
      }
    }
  }
}


var tripStateMachine = FiniteStateMachine(state: Trip.booking(destination: "Beethovenstraße"))
var tokenPool = FSMObservationTokenPool()

tripStateMachine.will(perform: .ordering) {
  print("Will order trip 1.")
}.retain(in: tokenPool)

tripStateMachine.will(perform: .ordering) {
  print("Will order trip 2.")
}.retain(in: tokenPool)

tripStateMachine.handle(.ordering) {
  print("Ordering trip.")
}

tripStateMachine.did(perform: .ordering) {
  print("Did order trip.")
}.retain(in: tokenPool)

tripStateMachine.did(enter: .traveling) {
  print("I started traveling.")
}.retain(in: tokenPool)

tripStateMachine.addHandler { transistion, oldState, newState in
  switch transistion {
  case .entering:
    print("Entering vehicle.")
  default:
    break
  }
}

tripStateMachine.did(leave: .traveling) {
  print("I stopped traveling.")
}.retain(in: tokenPool)

tripStateMachine.did(enter: .arrived) {
  print("I arrived!")
}.retain(in: tokenPool)

do {
  if !tripStateMachine.can(.entering) {
    print("You cannot enter the vehicle in this state (\(tripStateMachine.state)).")
    // print("Possible transitions: \(tripStateMachine.transitions)")
  }

  try tripStateMachine.perform(.ordering)
  try tripStateMachine.perform(.entering)
  try tripStateMachine.perform(.exiting)
} catch {
  dump(error)
  exit(1)
}
