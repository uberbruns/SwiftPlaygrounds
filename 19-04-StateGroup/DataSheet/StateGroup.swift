//
//  StateGroup.swift
//  DataSheet
//
//  Created by Karsten Bruns on 05.04.19.
//  Copyright © 2019 bruns.me. All rights reserved.
//

import Foundation


// MARK: - State Group -

public class StateGroup {

  private var nodes = [AnyState]()
  private var linkedGroups = [UInt: LinkedGroup]()

  private static var nextIdentifier: UInt = 0
  private let identifier: UInt

  public init() {
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

  private func register(_ node: AnyState) {
    var resolvedNodes = [AnyState]()

    nodes.append(node)

    for edge in node.edges {
      if edge.stateGroup != self && edge.stateGroup?.linkedGroups[identifier] == nil {
        let linkedGroup = LinkedGroup(self)
        edge.stateGroup?.linkedGroups[identifier] = linkedGroup
      }
    }

    resolve(resolvedNodesCollection: &resolvedNodes)
    callObservers(nodes: resolvedNodes)
  }

  fileprivate func update(with node: AnyState) {
    var resolvedNodes = [AnyState]()

    invalidate(node)
    resolve(resolvedNodesCollection: &resolvedNodes)
    callObservers(nodes: resolvedNodes)
  }

  private func invalidate(_ invalidNode: AnyState) {
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

  private func resolve(resolvedNodesCollection: inout [AnyState]) {
    var unresolvedNodes = nodes.filter { !$0.isResolved() }
    var solvedSomething = true
    var resolvedNodes = [AnyState]()

    while solvedSomething {
      solvedSomething = false

      for valueIndex in unresolvedNodes.indices.reversed() {
        let node = unresolvedNodes[valueIndex]
        let edges = node.edges

        let resolveNode = {
          node.resolve()
          unresolvedNodes.remove(at: valueIndex)
          solvedSomething = true
          resolvedNodes.append(node)
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

    resolvedNodesCollection += resolvedNodes

    for linkedGroup in linkedGroups.values {
      linkedGroup.reference?.resolve(resolvedNodesCollection: &resolvedNodesCollection)
    }
  }

  private func callObservers(nodes: [AnyState]) {
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
  public static func ==(lhs: StateGroup, rhs: StateGroup) -> Bool {
    return lhs.identifier == rhs.identifier
  }
}


// MARK: - State Object -
// MARK: Type-Eraser

fileprivate protocol AnyState: AnyObject {

  var stateGroup: StateGroup? { get }
  var valueChanged: Bool { get }
  var edges: [AnyState] { get }

  func isResolved() -> Bool
  func resolve()
  func reset()
  func callObserver()
}


extension StateGroup {

  // MARK: Base State Object

  public class State<R: Equatable>: AnyState {

    // MARK: Properties

    // Observability
    fileprivate var nextObserverUID: UInt = 0
    fileprivate var observations = [UInt: Observation]() {
      didSet {
        sortedObservations = observations.sorted(by: { $0.key < $1.key }).map({ $0.value })
      }
    }
    fileprivate var sortedObservations = [Observation]()

    // Linked Objects
    fileprivate weak var stateGroup: StateGroup?
    fileprivate var edges: [AnyState]

    // Value Evaluation
    private var currentValue: R?
    private var oldValue: R?
    fileprivate var valueChanged: Bool
    fileprivate var calculateValue: ([AnyState]) -> R

    // MARK: Life Cycle

    fileprivate init(stateGroup: StateGroup, edges: [AnyState], calculateValue: @escaping ([AnyState]) -> R) {
      self.calculateValue = calculateValue
      self.edges = edges
      self.stateGroup = stateGroup
      self.valueChanged = true
    }

    // MARK: API

    public var value: R {
      get {
        return currentValue!
      }
      set {
        assertionFailure("This state object does not provide a setter.")
      }
    }

    // MARK: State Evaluation

    fileprivate func reset() {
      oldValue = currentValue
      currentValue = nil
    }

    final fileprivate func isResolved() -> Bool {
      return currentValue != nil
    }

    final fileprivate func resolve() {
      currentValue = calculateValue(edges)
      valueChanged = oldValue != currentValue
      oldValue = nil
    }

    final fileprivate func callObserver() {
      for observation in sortedObservations {
        observation(value)
      }
    }
  }


  // MARK: Map State Object

  final fileprivate class Map<A: Equatable, R: Equatable>: State<R> {
    init(stateGroup: StateGroup, a: State<A>, body: @escaping (A) -> R) {
      super.init(stateGroup: stateGroup, edges: [a]) { edges -> R in
        let a = edges[0] as! State<A>
        return body(a.value)
      }
    }
  }


  // MARK: Zip State Objects

  final fileprivate class Zip2<A: Equatable, B: Equatable, R: Equatable>: State<R> {
    init(stateGroup: StateGroup, a: State<A>, b: State<B>, body: @escaping (A, B) -> R) {
      super.init(stateGroup: stateGroup, edges: [a, b]) { edges -> R in
        let a = edges[0] as! State<A>
        let b = edges[1] as! State<B>
        return body(a.value, b.value)
      }
    }
  }

  final fileprivate class Zip3<A: Equatable, B: Equatable, C: Equatable, R: Equatable>: State<R> {
    init(stateGroup: StateGroup, a: State<A>, b: State<B>, c: State<C>, body: @escaping (A, B, C) -> R) {
      super.init(stateGroup: stateGroup, edges: [a, b, c]) { edges -> R in
        let a = edges[0] as! State<A>
        let b = edges[1] as! State<B>
        let c = edges[2] as! State<C>
        return body(a.value, b.value, c.value)
      }
    }
  }

  final fileprivate class Zip4<A: Equatable, B: Equatable, C: Equatable, D: Equatable, R: Equatable>: State<R> {
    init(stateGroup: StateGroup, a: State<A>, b: State<B>, c: State<C>, d: State<D>, body: @escaping (A, B, C, D) -> R) {
      super.init(stateGroup: stateGroup, edges: [a, b, c, d]) { edges -> R in
        let a = edges[0] as! State<A>
        let b = edges[1] as! State<B>
        let c = edges[2] as! State<C>
        let d = edges[3] as! State<D>
        return body(a.value, b.value, c.value, d.value)
      }
    }
  }


  // MARK: Value State Object

  final fileprivate class Value<R: Equatable>: State<R> {
    private var newValue: R?

    final override var value: R {
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

    init(stateGroup: StateGroup, value: R) {
      self.newValue = value
      super.init(stateGroup: stateGroup, edges: []) { _ in fatalError() }
      calculateValue = { [unowned self] edges -> R in
          return self.newValue!
      }
    }
  }
}


// MARK: Convenience Extensions

extension StateGroup {
  public func value<R: Equatable>(_ value: R) -> State<R> {
    let node = Value(stateGroup: self, value: value)
    register(node)
    return node
  }

  public func map<A: Equatable, R: Equatable>(_ a: State<A>, body: @escaping (A) -> R) -> State<R> {
    let node = Map(stateGroup: self, a: a, body: body)
    register(node)
    return node
  }

  public func zip<A: Equatable, B: Equatable, R: Equatable>(_ a: State<A>, _ b: State<B>, body: @escaping (A, B) -> R) -> State<R> {
    let node = Zip2(stateGroup: self, a: a, b: b, body: body)
    register(node)
    return node
  }

  public func zip<A: Equatable, B: Equatable, C: Equatable, R: Equatable>(_ a: State<A>, _ b: State<B>, _ c: State<C>, body: @escaping (A, B, C) -> R) -> State<R> {
    let node = Zip3(stateGroup: self, a: a, b: b, c: c, body: body)
    register(node)
    return node
  }

  public func zip<A: Equatable, B: Equatable, C: Equatable, D: Equatable, R: Equatable>(_ a: State<A>, _ b: State<B>, _ c: State<C>, _ d: State<D>, body: @escaping (A, B, C, D) -> R) -> State<R> {
    let node = Zip4(stateGroup: self, a: a, b: b, c: c, d: d, body: body)
    register(node)
    return node
  }
}


// MARK: - Observability -

public class ObservationPool {
  fileprivate var tokens = [Any]()

  public init() { }
}


extension StateGroup.State {
  public class Token {
    fileprivate let uid: UInt
    fileprivate var deinitBlock: (() -> Void)?

    fileprivate init(uid: UInt) {
      self.uid = uid
    }

    deinit {
      deinitBlock?()
    }

    public func retain(in observationPool: ObservationPool) {
      observationPool.tokens.append(self)
    }
  }
}


extension StateGroup.State {
  public typealias Observation = (R) -> Void

  public func observe(_ block: @escaping Observation) -> Token {
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
