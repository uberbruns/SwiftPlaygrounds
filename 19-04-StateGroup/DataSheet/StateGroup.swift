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
      for edge in node.edges where edge.stateGroup != self {
        guard let edgeStateGroup = edge.stateGroup else { continue }
        edgeStateGroup.linkedGroups.removeValue(forKey: identifier)
      }
    }
  }

  private func register(_ node: Node) {
    var resolvedNodes = [Node]()

    nodes.append(node)

    for edge in node.edges {
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

    for affectedNode in nodes where affectedNode.edges.contains(where: { $0 === invalidNode }) {
      invalidate(affectedNode)
    }
  }

  private func resolve(resolvedNodes: inout [Node]) {
    var unresolvedNodes = nodes.filter { !$0.isResolved() }
    var solvedSomething = true
    var localResolvedNodes = [Node]()

    while solvedSomething {
      solvedSomething = false

      for valueIndex in unresolvedNodes.indices.reversed() {
        let node = unresolvedNodes[valueIndex]
        let edges = node.edges

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
          let isResolvable = !hasUnresolvedEdge
          if isResolvable {
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
    for node in nodes where node.valueChanged {
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

  // MARK: - Root Node -

  class Node: Hashable {

    weak var stateGroup: StateGroup?
    fileprivate var valueChanged = false
    fileprivate var edges: [Node]

    private static var nextNodeIdentifier = 0
    private let nodeIdentifier: Int

    static func ==(lhs: StateGroup.Node, rhs: StateGroup.Node) -> Bool {
      return lhs.hashValue == rhs.hashValue
    }

    fileprivate init(edges: [Node]) {
      self.edges = edges
      self.nodeIdentifier = Node.nextNodeIdentifier
      Node.nextNodeIdentifier += 1
    }

    func hash(into hasher: inout Hasher) {
      hasher.combine(nodeIdentifier)
    }

    func isResolved() -> Bool {
      fatalError("Node is not meant to be used directly. Use subclass instead.")
    }

    func resolve() {
      fatalError("Node is not meant to be used directly. Use subclass instead.")
    }

    func reset() {
      fatalError("Node is not meant to be used directly. Use subclass instead.")
    }

    fileprivate func callObserver() {
      fatalError("Node is not meant to be used directly. Use subclass instead.")
    }
  }


  // MARK: - State Node -

  class State<T: Equatable>: Node {

    // MARK: Properties

    // Observability
    fileprivate var nextObserverUID = 0
    fileprivate var observations = [Int: Observation]() {
      didSet {
        sortedObservations = observations.sorted(by: { $0.key < $1.key }).map({ $0.value })
      }
    }
    fileprivate var sortedObservations = [Observation]()

    // Node Evaluation
    fileprivate var evaluate: ([Node]) -> T
    private var storedValue: T?
    private var oldValue: T?

    var value: T {
      get {
        return storedValue!
      }
      set {
        assertionFailure("This node does not provide a setter.")
      }
    }

    // MARK: Life Cycle

    fileprivate init(stateGroup: StateGroup, edges: [Node], eval: @escaping ([Node]) -> T) {
      self.evaluate = eval
      super.init(edges: edges)
      self.stateGroup = stateGroup
    }

    // MARK: Node Characteristics

    final override func reset() {
      oldValue = storedValue
      storedValue = nil
    }

    final override func isResolved() -> Bool {
      return storedValue != nil
    }

    final override func resolve() {
      storedValue = evaluate(edges)
      valueChanged = oldValue != storedValue
      oldValue = nil
    }

    final override func callObserver() {
      for observation in sortedObservations {
        observation(value)
      }
    }
  }


  // MARK: - Map Node -

  final fileprivate class Map<A: Equatable, T: Equatable>: State<T> {
    init(stateGroup: StateGroup, a: State<A>, body: @escaping (A) -> T) {
      super.init(stateGroup: stateGroup, edges: [a]) { edges -> T in
        let a = edges[0] as! State<A>
        return body(a.value)
      }
    }
  }


  // MARK: - Zip Nodes -

  final fileprivate class Zip2<A: Equatable, B: Equatable, T: Equatable>: State<T> {
    init(stateGroup: StateGroup, a: State<A>, b: State<B>, body: @escaping (A, B) -> T) {
      super.init(stateGroup: stateGroup, edges: [a, b]) { edges -> T in
        let a = edges[0] as! State<A>
        let b = edges[1] as! State<B>
        return body(a.value, b.value)
      }
    }
  }

  final fileprivate class Zip3<A: Equatable, B: Equatable, C: Equatable, T: Equatable>: State<T> {
    init(stateGroup: StateGroup, a: State<A>, b: State<B>, c: State<C>, body: @escaping (A, B, C) -> T) {
      super.init(stateGroup: stateGroup, edges: [a, b, c]) { edges -> T in
        let a = edges[0] as! State<A>
        let b = edges[1] as! State<B>
        let c = edges[2] as! State<C>
        return body(a.value, b.value, c.value)
      }
    }
  }

  final fileprivate class Zip4<A: Equatable, B: Equatable, C: Equatable, D: Equatable, T: Equatable>: State<T> {
    init(stateGroup: StateGroup, a: State<A>, b: State<B>, c: State<C>, d: State<D>, body: @escaping (A, B, C, D) -> T) {
      super.init(stateGroup: stateGroup, edges: [a, b, c, d]) { edges -> T in
        let a = edges[0] as! State<A>
        let b = edges[1] as! State<B>
        let c = edges[2] as! State<C>
        let d = edges[3] as! State<D>
        return body(a.value, b.value, c.value, d.value)
      }
    }
  }

  // MARK: - Var Node -

  final fileprivate class Value<T: Equatable>: State<T> {
    private var newValue: T?

    final override var value: T {
      get {
        return super.value
      }
      set {
        if newValue != super.value {
          self.newValue = newValue
          stateGroup?.update(with: self)
        }
      }
    }

    init(stateGroup: StateGroup, value: T) {
      self.newValue = value
      super.init(stateGroup: stateGroup, edges: []) { _ in fatalError() }
      evaluate = { [unowned self] edges -> T in
          return self.newValue!
      }
    }
  }
}


// MARK: Convenience Extensions

extension StateGroup {
  func value<T: Equatable>(_ value: T) -> State<T> {
    let node = Value(stateGroup: self, value: value)
    register(node)
    return node
  }

  func map<A: Equatable, T: Equatable>(_ a: State<A>, body: @escaping (A) -> T) -> State<T> {
    let node = Map(stateGroup: self, a: a, body: body)
    register(node)
    return node
  }

  func zip<A: Equatable,
    B: Equatable,
    T: Equatable>
    (_ a: State<A>,
     _ b: State<B>,
     body: @escaping (A, B) -> T) -> State<T> {
    let node = Zip2(stateGroup: self, a: a, b: b, body: body)
    register(node)
    return node
  }

  func zip<
    A: Equatable,
    B: Equatable,
    C: Equatable, T: Equatable>
    (_ a: State<A>,
     _ b: State<B>,
     _ c: State<C>,
     body: @escaping (A, B, C) -> T) -> State<T> {
    let node = Zip3(stateGroup: self, a: a, b: b, c: c, body: body)
    register(node)
    return node
  }

  func zip<A: Equatable,
    B: Equatable,
    C: Equatable,
    D: Equatable,
    T: Equatable>
    (_ a: State<A>,
     _ b: State<B>,
     _ c: State<C>,
     _ d: State<D>,
     body: @escaping (A, B, C, D) -> T) -> State<T> {
    let node = Zip4(stateGroup: self, a: a, b: b, c: c, d: d, body: body)
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
    fileprivate var deinitBlock: (() -> Void)?

    fileprivate init(uid: Int) {
      self.uid = uid
    }

    deinit {
      deinitBlock?()
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
    token.deinitBlock = { [weak self] in
      self?.observations.removeValue(forKey: tokenUID)
    }
    observations[token.uid] = block
    nextObserverUID += 1
    return token
  }
}
