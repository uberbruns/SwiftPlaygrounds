//
//  StateGroup.swift
//  DataSheet
//
//  Created by Karsten Bruns on 05.04.19.
//  Copyright © 2019 bruns.me. All rights reserved.
//


import Combine
import Foundation


// MARK: - State Group -

public class StateGroup {

    static var shared = StateGroup()

    private var nodes = [StateObject]()
    private var linkedGroups = [UInt: LinkedGroup]()

    private static var nextIdentifier: UInt = 0
    private let identifier: UInt


    public init() {
        self.identifier = StateGroup.nextIdentifier
        StateGroup.nextIdentifier += 1
    }


    deinit {
        for node in nodes {
            for dependency in node.dependencies ?? [] where dependency.stateGroup != self {
                guard let dependencyStateGroup = dependency.stateGroup else { continue }
                dependencyStateGroup.linkedGroups.removeValue(forKey: identifier)
            }
        }
    }


    fileprivate func register(_ node: StateObject) {
        var resolvedNodes = [StateObject]()

        nodes.append(node)

        for dependency in node.dependencies ?? [] {
            if dependency.stateGroup != self && dependency.stateGroup?.linkedGroups[identifier] == nil {
                let linkedGroup = LinkedGroup(self)
                dependency.stateGroup?.linkedGroups[identifier] = linkedGroup
            }
        }

        resolve(resolvedNodesCollection: &resolvedNodes)
        callObservers(nodes: resolvedNodes)
    }


    fileprivate func update(with node: StateObject) {
        var resolvedNodes = [StateObject]()

        invalidate(node)
        resolve(resolvedNodesCollection: &resolvedNodes)
        callObservers(nodes: resolvedNodes)
    }


    private func invalidate(_ invalidNode: StateObject) {
        invalidNode.reset()

        for weakState in invalidNode.dependees.values {
            guard let dependee = weakState.state else { continue }
            dependee.stateGroup?.invalidate(dependee)
        }
    }


    private func resolve(resolvedNodesCollection: inout [StateObject]) {
        var unresolvedNodes = nodes.filter { !$0.isResolved() }
        var didSolveSomething = true
        var resolvedNodes = [StateObject]()

        while didSolveSomething {
            didSolveSomething = false

            for valueIndex in unresolvedNodes.indices.reversed() {
                let node = unresolvedNodes[valueIndex]
                let dependencies = node.dependencies ?? []

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


    private func callObservers(nodes: [StateObject]) {
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


// MARK: Mutable State Object

@propertyWrapper
final class Mutable<R: Equatable>: State<R> {
    private var newValue: R?

    final var wrappedValue: R {
        get {
            return super.currentValue
        }
        set {
            if newValue != super.currentValue {
                self.newValue = newValue
                stateGroup?.update(with: self)
            }
        }
    }

    public var projectedValue: Mutable<R> {
        get { self }
    }

    init(wrappedValue: R) {
        self.newValue = wrappedValue
        super.init()
        self.configure(dependencies: []) { [unowned self] dependencies -> R in
            return self.newValue!
        }
    }
}


// MARK: - State Object -

// MARK: Base State Object

public class State<R: Equatable>: StateObject, Publisher {

    // MARK: Properties

    // Identity
    private let identifier: UInt

    // Linked Objects
    fileprivate weak var stateGroup: StateGroup?
    fileprivate var dependencies: [StateObject]?
    fileprivate var dependees: [UInt: WeakState]

    // Value Evaluation
    fileprivate var currentValue: R!
    fileprivate var oldValue: R?
    fileprivate var valueChanged: Bool
    fileprivate var calculateValue: (([StateObject]) -> R)?

    // Subscriptions
    fileprivate var subscriptions = [CombineIdentifier: (R) -> Void]()

    // MARK: Life Cycle

    fileprivate init() {
        self.identifier = StateStatics.nextIdentifier
        self.dependees = [:]
        self.stateGroup = StateGroup.shared
        self.valueChanged = true

        StateStatics.nextIdentifier += 1
    }


    fileprivate func configure(dependencies: [StateObject], calculateValue: @escaping ([StateObject]) -> R) {
        self.calculateValue = calculateValue
        self.dependencies = dependencies

        for dependency in dependencies {
            dependency.dependees[identifier] = WeakState(self)
        }
        stateGroup?.register(self)
   }


    deinit {
        guard let dependencies = dependencies else { return }
        for dependency in dependencies {
            dependency.dependees.removeValue(forKey: identifier)
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
        guard let calculateValue = calculateValue, let dependencies = dependencies else {
            assertionFailure("You try to resolve that was not set up, yet.")
            return
        }

        currentValue = calculateValue(dependencies)
        valueChanged = oldValue != currentValue
        oldValue = nil
    }


    final fileprivate func callObserver() {
        for (_ ,subscription) in subscriptions {
            subscription(currentValue)
        }
    }


    // MARK: Publisher Conformance

    public typealias Output = R
    public typealias Failure = Never

    public func receive<S>(subscriber: S) where S : Subscriber, S.Failure == Failure, S.Input == Output {
        subscriber.receive(
            subscription: StateSubscription(subscriber: subscriber, stateObject: self)
        )
    }
}


// MARK: Computed State Object

@propertyWrapper
final class Computed<R: Equatable>: State<R> {
    final var wrappedValue: R {
        get {
            currentValue
        }
    }

    override init() {
        super.init()
    }

    public var projectedValue: Computed<R> {
        get { self }
    }

    func map<A: Equatable>(_ a: State<A>, _ body: @escaping (A) -> R) {
        configure(dependencies: [a]) { dependencies -> R in
            let a = dependencies[0] as! State<A>
            return body(a.currentValue)
        }
    }

    func zip<A: Equatable, B: Equatable>(_ a: State<A>, _ b: State<B>, _ body: @escaping (A, B) -> R) {
        configure(dependencies: [a, b]) { dependencies -> R in
            let a = dependencies[0] as! State<A>
            let b = dependencies[1] as! State<B>
            return body(a.currentValue, b.currentValue)
        }
    }

    func zip<A: Equatable, B: Equatable, C: Equatable>(_ a: State<A>, _ b: State<B>, _ c: State<C>, _ body: @escaping (A, B, C) -> R) {
        configure(dependencies: [a, b, c]) { dependencies -> R in
            let a = dependencies[0] as! State<A>
            let b = dependencies[1] as! State<B>
            let c = dependencies[2] as! State<C>
            return body(a.currentValue, b.currentValue, c.currentValue)
        }
    }

    func zip<A: Equatable, B: Equatable, C: Equatable, D: Equatable>(_ a: State<A>, _ b: State<B>, _ c: State<C>, _ d: State<D>, _ body: @escaping (A, B, C, D) -> R) {
        configure(dependencies: [a, b, c, d]) { dependencies -> R in
            let a = dependencies[0] as! State<A>
            let b = dependencies[1] as! State<B>
            let c = dependencies[2] as! State<C>
            let d = dependencies[3] as! State<D>
            return body(a.currentValue, b.currentValue, c.currentValue, d.currentValue)
        }
    }
}


// MARK: Supporting Types

fileprivate protocol StateObject: AnyObject {
    var stateGroup: StateGroup? { get }
    var valueChanged: Bool { get }
    var dependencies: [StateObject]? { get }
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
    weak var state: StateObject?

    init(_ state: StateObject) {
        self.state = state
    }
}


// MARK: - Combine -

final class StateSubscription<R: Equatable, SB: Subscriber, ST: State<R>>: Subscription where SB.Input == R {
    private var subscriber: SB?
    private weak var stateObject: ST?

    init(subscriber: SB, stateObject: ST) {
        self.subscriber = subscriber
        self.stateObject = stateObject

        stateObject.subscriptions[combineIdentifier] = { value in
            // Self is now captured in `stateObject.subscriptions`. This should keep this
            // instance alive until cancelled.
            _ = self.subscriber?.receive(value)
        }
    }

    func request(_ demand: Subscribers.Demand) {
        // We do nothing here as we only want to send events when they occur.
        // See, for more info: https://developer.apple.com/documentation/combine/subscribers/demand
    }

    func cancel() {
        subscriber = nil
        stateObject?.subscriptions.removeValue(forKey: combineIdentifier)
    }
}
