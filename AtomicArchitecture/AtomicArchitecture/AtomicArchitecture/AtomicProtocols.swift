//
//  AtomicProtocols.swift
//  AtomicArchitecture
//
//  Created by Karsten Bruns on 30.06.18.
//  Copyright © 2018 Karsten Bruns. All rights reserved.
//

import UIKit


protocol AnySystem: AnyObject {
  func environmentDidChangeState(to state: EnvironmentState, oldState: EnvironmentState)
}


protocol System: AnySystem {
  associatedtype EnvironmentType: Environment
  func updateEnvironment()
  var environment: EnvironmentType { get }
}


protocol Molecule {
  var identity: AnyHashable { get }
  var hashValue: Int { get }
}


protocol Organism { }


protocol Environment: AnyObject {
  var system: AnySystem? { get set }
  func refresh()
}


enum EnvironmentState {
  case initialized
  case didLoad
  case willAppear
  case didAppear
  case willDisappear
  case didDisappear
}


///////////////////////////////////////

class MessageListSystem<E>: System where E: ContentEnvironment, E: HeaderEnvironment {

  typealias EnvironmentType = E

  var environment: E

  init(environment: E) {
    self.environment = environment
  }

  func updateEnvironment() {
    let actions = ContentOrganism(identity: "actions", molecules: { () -> [ContentMolecule] in
      let done = ActionMolecule(identity: "newMessage", title: "New Message")
      return [done]
    }())

    environment.contentOrganisms = [actions]
    environment.refresh()
  }

  func environmentDidChangeState(to state: EnvironmentState, oldState: EnvironmentState) {
    if state == .didLoad {
      updateEnvironment()
    }
  }
}


///////////////////////////////////////


protocol ContentEnvironment: Environment {
  var contentOrganisms: [ContentOrganism] { get set }
}


struct ContentOrganism: Organism {
  let identity: AnyHashable
  var molecules: [ContentMolecule]
}


protocol ContentMolecule: Molecule {
  var type: String { get }
}


////

protocol HeaderEnvironment: Environment {
  var headerOrganisms: [HeaderOrganism] { get set }
}


struct HeaderOrganism: Organism {
  let identity: AnyHashable
  var molecules: [HeaderMolecule]
}


protocol HeaderMolecule: Molecule {
}


////


protocol ToolbarMolecule: Molecule {
}


////////////


struct ActionMolecule: ContentMolecule, HeaderMolecule, ToolbarMolecule, Hashable {
  let identity: AnyHashable
  let type = "action"
  var title: String

  init(identity: AnyHashable, title: String) {
    self.identity = identity
    self.title = title
  }
}


////////////


class StandardEnvironmentViewController: UIViewController, ContentEnvironment, HeaderEnvironment {

  weak var system: AnySystem?

  var contentOrganisms = [ContentOrganism]()
  var headerOrganisms = [HeaderOrganism]()

  var state = EnvironmentState.initialized {
    didSet {
      system?.environmentDidChangeState(to: state, oldState: oldValue)
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    state = .didLoad
  }

  func refresh() { }
}
