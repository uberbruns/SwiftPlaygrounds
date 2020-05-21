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
      for dependency in node.dependencies where dependency.stateGroup != self {
        guard let dependencyStateGroup = dependency.stateGroup else { continue }
        dependencyStateGroup.linkedGroups.removeValue(forKey: identifier)
      }
    }
  }


  private func register(_ node: AnyState) {
    var resolvedNodes = [AnyState]()

    nodes.append(node)

    for dependency in node.dependencies {
      if dependency.stateGroup != self && dependency.stateGroup?.linkedGroups[identifier] == nil {
        let linkedGroup = LinkedGroup(self)
        dependency.stateGroup?.linkedGroups[identifier] = linkedGroup
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

    for weakState in invalidNode.dependees.values {
      guard let dependee = weakState.state else { continue }
      dependee.stateGroup?.invalidate(dependee)
    }
  }


  private func resolve(resolvedNodesCollection: inout [AnyState]) {
    var unresolvedNodes = nodes.filter { !$0.isResolved() }
    var didSolveSomething = true
    var resolvedNodes = [AnyState]()

    while didSolveSomething {
      didSolveSomething = false

      for valueIndex in unresolvedNodes.indices.reversed() {
        let node = unresolvedNodes[valueIndex]
        let dependencies = node.dependencies

        let resolveNode = {
          node.resolve()
          unresolvedNodes.remove(at: valueIndex)
          didSolveSomething = true
          resolvedNodes.append(node)
        }

        if dependencies.isEmpty {
          resolveNode()
        } else {
          let hasUnresolvedEdge = dependencies.contains { !$0.isResolved() }
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

extension StateGroup {

  // MARK: Base State Object

  public class State<R: Equatable>: AnyState {

    // MARK: Properties

    // Identity
    private let identifier: UInt

    // Linked Objects
    fileprivate weak var stateGroup: StateGroup?
    fileprivate var dependencies: [AnyState]
    fileprivate var dependees: [UInt: WeakState]

    // Value Evaluation
    private var currentValue: R?
    private var oldValue: R?
    fileprivate var valueChanged: Bool
    fileprivate var calculateValue: ([AnyState]) -> R

    // Observability
    fileprivate var nextObserverUID: UInt = 0
    fileprivate var observations = [UInt: Observation]() {
      didSet {
        sortedObservations = observations.sorted(by: { $0.key < $1.key }).map({ $0.value })
      }
    }
    fileprivate var sortedObservations = [Observation]()

    // MARK: Life Cycle

    fileprivate init(stateGroup: StateGroup, dependencies: [AnyState], calculateValue: @escaping ([AnyState]) -> R) {
      self.identifier = StateStatics.nextIdentifier
      self.calculateValue = calculateValue
      self.dependencies = dependencies
      self.dependees = [:]
      self.stateGroup = stateGroup
      self.valueChanged = true

      StateStatics.nextIdentifier += 1
      for dependency in dependencies {
        dependency.dependees[identifier] = WeakState(self)
      }
    }


    deinit {
      for dependency in dependencies {
        dependency.dependees.removeValue(forKey: identifier)
      }
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
      currentValue = calculateValue(dependencies)
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
      super.init(stateGroup: stateGroup, dependencies: [a]) { dependencies -> R in
        let a = dependencies[0] as! State<A>
        return body(a.value)
      }
    }
  }


  // MARK: Zip State Objects

  final fileprivate class Zip2<A: Equatable, B: Equatable, R: Equatable>: State<R> {
    init(stateGroup: StateGroup, a: State<A>, b: State<B>, body: @escaping (A, B) -> R) {
      super.init(stateGroup: stateGroup, dependencies: [a, b]) { dependencies -> R in
        let a = dependencies[0] as! State<A>
        let b = dependencies[1] as! State<B>
        return body(a.value, b.value)
      }
    }
  }

  final fileprivate class Zip3<A: Equatable, B: Equatable, C: Equatable, R: Equatable>: State<R> {
    init(stateGroup: StateGroup, a: State<A>, b: State<B>, c: State<C>, body: @escaping (A, B, C) -> R) {
      super.init(stateGroup: stateGroup, dependencies: [a, b, c]) { dependencies -> R in
        let a = dependencies[0] as! State<A>
        let b = dependencies[1] as! State<B>
        let c = dependencies[2] as! State<C>
        return body(a.value, b.value, c.value)
      }
    }
  }

  final fileprivate class Zip4<A: Equatable, B: Equatable, C: Equatable, D: Equatable, R: Equatable>: State<R> {
    init(stateGroup: StateGroup, a: State<A>, b: State<B>, c: State<C>, d: State<D>, body: @escaping (A, B, C, D) -> R) {
      super.init(stateGroup: stateGroup, dependencies: [a, b, c, d]) { dependencies -> R in
        let a = dependencies[0] as! State<A>
        let b = dependencies[1] as! State<B>
        let c = dependencies[2] as! State<C>
        let d = dependencies[3] as! State<D>
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
      super.init(stateGroup: stateGroup, dependencies: []) { _ in fatalError() }
      calculateValue = { [unowned self] dependencies -> R in
          return self.newValue!
      }
    }
  }
}



// MARK: Supporting Types

fileprivate protocol AnyState: AnyObject {
  var stateGroup: StateGroup? { get }
  var valueChanged: Bool { get }
  var dependencies: [AnyState] { get }
  var dependees: [UInt: WeakState] { get set }

  func isResolved() -> Bool
  func resolve()
  func reset()
  func callObserver()
}


fileprivate enum StateStatics {
  static var nextIdentifier: UInt = 0
}


fileprivate class WeakState {
  weak var state: AnyState?

  init(_ state: AnyState) {
    self.state = state
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

public class Holder {
  fileprivate var hooks = [Any]()

  public init() { }
}



extension StateGroup.State {
  public class Hook {
    fileprivate let uid: UInt
    fileprivate var deinitBlock: (() -> Void)?

    fileprivate init(uid: UInt) {
      self.uid = uid
    }

    deinit {
      deinitBlock?()
    }

    public func attach(to holder: Holder) {
      holder.hooks.append(self)
    }
  }
}



extension StateGroup.State {
  public typealias Observation = (R) -> Void

  public func observe(_ block: @escaping Observation) -> Hook {
    let hookUID = nextObserverUID
    let hook = Hook(uid: hookUID)
    hook.deinitBlock = { [weak self] in
      self?.observations.removeValue(forKey: hookUID)
    }
    observations[hook.uid] = block
    nextObserverUID += 1
    return hook
  }
}
