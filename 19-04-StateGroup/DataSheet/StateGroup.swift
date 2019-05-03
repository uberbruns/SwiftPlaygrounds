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
  private var linkedGroups = [UInt: LinkedGroup]()

  private static var nextIdentifier: UInt = 0
  private let identifier: UInt

  init() {
    self.identifier = StateGroup.nextIdentifier
    StateGroup.nextIdentifier += 1
  }

  deinit {
    for node in nodes {
      for edge in node.edges() where edge.stateGroup != self {
        guard let edgeStateGroup = edge.stateGroup else { continue }
        edgeStateGroup.linkedGroups.removeValue(forKey: identifier)
      }
    }
  }

  private func register(_ node: Node) {
    var resolvedNodes = [Node]()

    nodes.append(node)

    for edge in node.edges() {
      if edge.stateGroup != self && edge.stateGroup?.linkedGroups[identifier] == nil {
        let linkedGroup = LinkedGroup(self)
        edge.stateGroup?.linkedGroups[identifier] = linkedGroup
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

    for linkedGroup in linkedGroups.values {
      if let childStateGroup = linkedGroup.reference {
        childStateGroup.invalidate(invalidNode)
      }
    }

    for affectedNode in nodes where affectedNode.edges().contains(where: { $0 === invalidNode }) {
      invalidate(affectedNode)
    }
  }

  private func resolve(resolvedNodes: inout [Node]) {
    // This algorithm is just a proof of concept and should be replace with
    // a proper graph resolver.
    var unresolvedNodes = nodes.filter { !$0.isResolved() }
    var solvedSomething = true
    var localResolvedNodes = [Node]()

    while solvedSomething {
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

    for linkedGroup in linkedGroups.values {
      linkedGroup.reference?.resolve(resolvedNodes: &resolvedNodes)
    }
  }

  private func callObservers(nodes: [Node]) {
    for node in nodes where node.valueChanged() {
      node.callObserver()
    }
  }
}


// MARK: Supporting Types

fileprivate extension StateGroup {
  struct LinkedGroup {
    weak var reference: StateGroup?

    init(_ stateGroup: StateGroup) {
      self.reference = stateGroup
    }
  }
}


// MARK: Protocol Conformance

extension StateGroup: Equatable {
  static func ==(lhs: StateGroup, rhs: StateGroup) -> Bool {
    return lhs.identifier == rhs.identifier
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
      fatalError("Node is not meant to be used directly. Use subclass instead.")
    }

    func edges() -> [Node] {
      fatalError("Node is not meant to be used directly. Use subclass instead.")
    }

    func resolve() {
      fatalError("Node is not meant to be used directly. Use subclass instead.")
    }

    func reset() {
      fatalError("Node is not meant to be used directly. Use subclass instead.")
    }

    fileprivate func valueChanged() -> Bool {
      fatalError("Node is not meant to be used directly. Use subclass instead.")
    }

    fileprivate func callObserver() {
      fatalError("Node is not meant to be used directly. Use subclass instead.")
    }
  }


  class State<T: Equatable>: Node {
    fileprivate var nextObserverUID = 0
    fileprivate var observations = [Int: Observation]() {
      didSet {
        sortedObservations = observations.sorted(by: { $0.key < $1.key }).map({ $0.value })
      }
    }
    fileprivate var sortedObservations = [Observation]()

    var value: T {
      get {
        fatalError("State<T> is not meant to be used directly. Use subclass instead.")
      }
      set {
        fatalError("State<T> is not meant to be used directly. Use subclass instead.")
      }
    }

    fileprivate override init() {
      super.init()
    }

    override func callObserver() {
      for observation in sortedObservations {
        observation(value)
      }
    }
  }


  class Variable<T: Equatable>: State<T> {
    private var _value: T?
    private var _oldValue: T?
    private var _newValue: T?
    private var _valueChanged: Bool

    override var value: T {
      get {
        return _value!
      }
      set {
        if newValue != _value {
          _newValue = newValue
          stateGroup?.update(with: self)
        }
      }
    }

    init(stateGroup: StateGroup, value: T) {
      self._value = value
      self._newValue = nil
      self._valueChanged = true
      super.init()
      self.stateGroup = stateGroup
    }

    override func edges() -> [StateGroup.Node] {
      return []
    }

    override func valueChanged() -> Bool {
      return _valueChanged
    }

    override func reset() {
      _oldValue = _value
      _value = nil
    }

    override func isResolved() -> Bool {
      return _value != nil
    }

    override func resolve() {
      _value = _newValue
      _valueChanged = _oldValue != _value
      _newValue = nil
      _oldValue = nil
    }
  }


  fileprivate class Map<A: Equatable, T: Equatable>: State<T> {
    private let a: State<A>
    private let body: (A) -> T

    private let _edges: [Node]
    private var _value: T?
    private var _oldValue: T?
    private var _valueChanged: Bool

    override var value: T {
      get {
        return _value!
      }
      set {
        assertionFailure("A map node does not provide a setter.")
      }
    }

    init(stateGroup: StateGroup, a: State<A>, body: @escaping (A) -> T) {
      self._edges = [a]
      self._valueChanged = true
      self.a = a
      self.body = body
      super.init()
      self.stateGroup = stateGroup
    }

    override func edges() -> [Node] {
      return _edges
    }

    override func valueChanged() -> Bool {
      return _valueChanged
    }

    override func reset() {
      _oldValue = _value
      _value = nil
    }

    override func isResolved() -> Bool {
      return _value != nil
    }

    override func resolve() {
      _value = body(a.value)
      _valueChanged = _oldValue != _value
      _oldValue = nil
    }
  }


  fileprivate class Zip<A: Equatable, B: Equatable, T: Equatable>: State<T> {
    private let _edges: [Node]
    private var _value: T?
    private var _valueChanged: Bool
    private var _oldValue: T?

    private let a: State<A>
    private let b: State<B>
    private let body: (A, B) -> T

    override var value: T {
      get {
        return _value!
      }
      set {
        assertionFailure("A zip node does not provide a setter.")
      }
    }

    init(stateGroup: StateGroup, a: State<A>, b: State<B>, body: @escaping (A, B) -> T) {
      self.a = a
      self.b = b
      self._edges = [a, b]
      self._valueChanged = true
      self.body = body
      super.init()
      self.stateGroup = stateGroup
    }

    override func edges() -> [Node] {
      return _edges
    }

    override func valueChanged() -> Bool {
      return _valueChanged
    }

    override func reset() {
      _oldValue = _value
      _value = nil
    }

    override func isResolved() -> Bool {
      return _value != nil
    }

    override func resolve() {
      _value = body(a.value, b.value)
      _valueChanged = _oldValue != _value
      _oldValue = nil
    }
  }
}


// MARK: Convenience Extensions

extension StateGroup {
  func variable<T: Equatable>(_ value: T) -> State<T> {
    let node = Variable(stateGroup: self, value: value)
    register(node)
    return node
  }

  func map<A: Equatable, T: Equatable>(_ a: State<A>, body: @escaping (A) -> T) -> State<T> {
    let node = Map(stateGroup: self, a: a, body: body)
    register(node)
    return node
  }

  func zip<A: Equatable, B: Equatable, T: Equatable>(_ a: State<A>, _ b: State<B>, body: @escaping (A, B) -> T) -> State<T> {
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
    let tokenUID = nextObserverUID
    let token = Token(uid: tokenUID)
    token.deinitialization = { [weak self] in
      self?.observations.removeValue(forKey: tokenUID)
    }
    observations[token.uid] = block
    nextObserverUID += 1
    return token
  }
}
