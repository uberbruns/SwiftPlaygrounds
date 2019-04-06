//
//  StateGroup.swift
//  DataSheet
//
//  Created by Karsten Bruns on 05.04.19.
//  Copyright © 2019 bruns.me. All rights reserved.
//

import Foundation


// MARK: - State Group -

class StateGroup {

  private var nodes = [Node]()
  private var childGroups = [UInt: ChildGroups]()

  private static var nextPoolIdentifier: UInt = 0
  private let poolIdentifier: UInt

  init() {
    self.poolIdentifier = StateGroup.nextPoolIdentifier
    StateGroup.nextPoolIdentifier += 1
  }

  deinit {
    for node in nodes {
      for edge in node.edges() where edge.stateGroup != self {
        guard let edgeStateGroup = edge.stateGroup else { continue }
        edgeStateGroup.childGroups.removeValue(forKey: poolIdentifier)
      }
    }
  }

  private func register(_ node: Node) {
    var resolvedNodes = [Node]()

    nodes.append(node)
    for edge in node.edges() {
      if edge.stateGroup != self && edge.stateGroup?.childGroups[poolIdentifier] == nil {
        let childGroup = ChildGroups(stateGroup: self)
        edge.stateGroup?.childGroups[poolIdentifier] = childGroup
      }
    }

    resolve(resolvedNodes: &resolvedNodes)
    callObservers(nodes: resolvedNodes)
  }

  fileprivate func update(with node: Node) {
    var resolvedNodes = [Node]()

    invalidate(node)
    resolve(resolvedNodes: &resolvedNodes)
    callObservers(nodes: resolvedNodes)
  }

  private func invalidate(_ invalidNode: Node) {
    invalidNode.reset()

    for childGroup in childGroups.values {
      if let childStateGroup = childGroup.stateGroup {
        childStateGroup.invalidate(invalidNode)
      }
    }

    for anotherNode in nodes where anotherNode.edges().contains(where: { $0 === invalidNode }) {
      anotherNode.stateGroup?.invalidate(anotherNode)
    }
  }

  private func resolve(resolvedNodes: inout [Node]) {
    // This algorithm is just a proof of concept and should be replace with
    // a proper graph resolver.
    var unresolvedNodes = nodes.filter { !$0.isResolved() }
    var solvedSomething = true
    var localResolvedNodes = [Node]()

    while solvedSomething == true {
      solvedSomething = false

      for valueIndex in unresolvedNodes.indices.reversed() {
        let node = unresolvedNodes[valueIndex]
        let edges = node.edges()

        let resolveNode = {
          node.resolve()
          unresolvedNodes.remove(at: valueIndex)
          solvedSomething = true
          localResolvedNodes.append(node)
        }

        if edges.isEmpty {
          resolveNode()
        } else {
          let hasUnresolvedEdge = edges.contains { !$0.isResolved() }
          if !hasUnresolvedEdge {
            resolveNode()
          }
        }
      }
    }

    resolvedNodes += localResolvedNodes

    for childGroup in childGroups.values {
      childGroup.stateGroup?.resolve(resolvedNodes: &resolvedNodes)
    }
  }

  private func callObservers(nodes: [Node]) {
    for node in nodes {
      node.callObserver()
    }
  }
}


// MARK: Supporting Types

extension StateGroup {
  struct ChildGroups {
    weak var stateGroup: StateGroup?

    init(stateGroup: StateGroup) {
      self.stateGroup = stateGroup
    }
  }
}


// MARK: Protocol Conformance

extension StateGroup: Equatable {
  static func ==(lhs: StateGroup, rhs: StateGroup) -> Bool {
    return lhs.poolIdentifier == rhs.poolIdentifier
  }
}


// MARK: - Node Types -

extension StateGroup {
  class Node: Hashable {

    weak var stateGroup: StateGroup?
    private static var nextNodeIdentifier = 0
    private let nodeIdentifier: Int

    static func == (lhs: StateGroup.Node, rhs: StateGroup.Node) -> Bool {
      return lhs.hashValue == rhs.hashValue
    }

    init() {
      self.nodeIdentifier = Node.nextNodeIdentifier
      Node.nextNodeIdentifier += 1
    }

    func hash(into hasher: inout Hasher) {
      hasher.combine(nodeIdentifier)
    }

    func isResolved() -> Bool {
      return true
    }

    func edges() -> [Node] {
      return []
    }

    func resolve() { }

    func reset() { }

    func callObserver() { }
  }


  class State<T>: Node {
    fileprivate var nextObserverUID = 0
    fileprivate var observations = [Int: Observation]() {
      didSet {
        sortedObservations = observations.sorted(by: { $0.key < $1.key }).map({ $0.value })
      }
    }
    fileprivate var sortedObservations = [Observation]()

    var value: T {
      get {
        fatalError()
      }
    }

    override func callObserver() {
      for observation in sortedObservations {
        observation(value)
      }
    }
  }

  class Variable<T>: State<T> {
    private var _value: T

    override var value: T {
      get {
        return _value
      }
      set {
        _value = newValue
        stateGroup?.update(with: self)
      }
    }

    init(stateGroup: StateGroup, value: T) {
      self._value = value
      super.init()
      self.stateGroup = stateGroup
    }
  }


  fileprivate class Map<A, T>: State<T> {
    let a: State<A>
    let body: (A) -> T

    private let _edges: [Node]

    private var _value: T?
    override var value: T {
      get {
        return _value!
      }
    }

    init(stateGroup: StateGroup, a: State<A>, body: @escaping (A) -> T) {
      self.a = a
      self._edges = [a]
      self.body = body
      super.init()
      self.stateGroup = stateGroup
    }

    override func edges() -> [Node] {
      return _edges
    }

    override func reset() {
      _value = nil
    }

    override func isResolved() -> Bool {
      return _value != nil
    }

    override func resolve() {
      _value = body(a.value)
    }
  }


  fileprivate class Zip<A, B, T>: State<T> {
    let a: State<A>
    let b: State<B>
    let body: (A, B) -> T

    private let _edges: [Node]

    private var _value: T?
    override var value: T {
      get {
        return _value!
      }
    }

    init(stateGroup: StateGroup, a: State<A>, b: State<B>, body: @escaping (A, B) -> T) {
      self.a = a
      self.b = b
      self._edges = [a, b]
      self.body = body
      super.init()
      self.stateGroup = stateGroup
    }

    override func edges() -> [Node] {
      return _edges
    }

    override func reset() {
      _value = nil
    }

    override func isResolved() -> Bool {
      return _value != nil
    }

    override func resolve() {
      _value = body(a.value, b.value)
    }
  }
}


// MARK: Convenience Extensions

extension StateGroup {
  func variable<T>(_ value: T) -> Variable<T> {
    let node = Variable(stateGroup: self, value: value)
    register(node)
    return node
  }

  func map<A, T>(_ a: State<A>, body: @escaping (A) -> T) -> State<T> {
    let node = Map(stateGroup: self, a: a, body: body)
    register(node)
    return node
  }

  func zip<A, B, T>(_ a: State<A>, _ b: State<B>, body: @escaping (A, B) -> T) -> State<T> {
    let node = Zip(stateGroup: self, a: a, b: b, body: body)
    register(node)
    return node
  }
}


// MARK: Observability

class ObservationPool {
  fileprivate var tokens = [Any]()

  init() { }
}

extension StateGroup.State {
  class Token {

    fileprivate let uid: Int
    fileprivate var deinitialization: (() -> Void)?

    fileprivate init(uid: Int) {
      self.uid = uid
    }

    deinit {
      deinitialization?()
    }

    func retain(in observationPool: ObservationPool) {
      observationPool.tokens.append(self)
    }
  }
}


extension StateGroup.State {
  typealias Observation = (T) -> Void


  func observe(_ block: @escaping Observation) -> Token {
    let token = Token(uid: nextObserverUID)
    token.deinitialization = { [weak self] in
      self?.observations.removeValue(forKey: token.uid)
    }
    observations[token.uid] = block
    nextObserverUID += 1
    return token
  }
}

