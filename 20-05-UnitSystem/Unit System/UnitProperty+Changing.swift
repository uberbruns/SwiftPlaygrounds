//
//  UnitProperty+Changing.swift
//  Unit System
//
//  Created by Karsten Bruns on 22.05.20.
//  Copyright © 2020 Karsten Bruns. All rights reserved.
//

import Combine
import Foundation


@propertyWrapper
final class Changing<V: Equatable>: UnitProperty {

    // Property
    private var value: V

    // Subscriptions
    fileprivate var subscriptions = [CombineIdentifier: (V) -> Void]()

    var wrappedValue: V {
        get {
            value
        }
        set {
            guard newValue != value else { return }
            value = newValue
            for (_ ,subscription) in subscriptions {
                subscription(value)
            }
        }
    }

    public var projectedValue: Changing<V> {
        get { self }
    }

    init(wrappedValue: V) {
        self.value = wrappedValue
    }


    // MARK: Publisher Conformance

    public typealias Output = V
    public typealias Failure = Never

    public func receive<S>(subscriber: S) where S : Subscriber, S.Failure == Failure, S.Input == Output {
        subscriber.receive(
            subscription: OutputSubscription(subscriber: subscriber, stateObject: self)
        )
    }
}


// MARK: - Combine -

final class OutputSubscription<V: Equatable, SB: Subscriber, O: Changing<V>>: Subscription where SB.Input == V {
    private var subscriber: SB?
    private weak var output: O?

    init(subscriber: SB, stateObject: O) {
        self.subscriber = subscriber
        self.output = stateObject

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
        output?.subscriptions.removeValue(forKey: combineIdentifier)
    }
}
