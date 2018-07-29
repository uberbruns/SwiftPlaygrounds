//
//  main.swift
//  Connections
//
//  Created by Karsten Bruns on 28.07.18.
//  Copyright © 2018 Karsten Bruns. All rights reserved.
//

import Foundation

enum ConnectionState {
    case preparing
    case running(task: Any)
    case succeeded(response: HTTPURLResponse, result: Any)
    case failed(response: HTTPURLResponse, error: Any)
}


protocol Connection {
    var log: String { get set }
    // var request: String { get set }
    // var state: ConnectionState { get set }
}


protocol APIConnection: Connection {
    // var apiKey: String  { get }
}


protocol Plug {
    associatedtype ConnectionType
    init()
    func execute(connection: ConnectionType, completion completionHandler: (ConnectionType) -> ())
}


struct APICredentialsPlug<C>: Plug where C: APIConnection {
    func execute(connection: C, completion completionHandler: (C) -> ()) {
        var connection = connection
        print("api", connection.log)
        connection.log += "api"
        completionHandler(connection)
    }

    init() {
    }

    typealias ConnectionType = C
}


struct RequestPlug<C>: Plug where C: Connection {
    func execute(connection: C, completion completionHandler: (C) -> ()) {
        var connection = connection
        print("request", connection.log)
        connection.log += "request"
        completionHandler(connection)
    }

    init() {
    }

    typealias ConnectionType = C
}


struct MyConnnection: APIConnection {
    var log = ""
    // var request: String
    // var state = ConnectionState.preparing

    init() {
        // self.request = url.absoluteString
    }
}


struct Torch {

    struct Step<C: Connection> {

        typealias AsyncWork = (C, (C) -> Void) -> Void
        private let asyncWork: AsyncWork

        private init(asyncWork: @escaping AsyncWork) {
            self.asyncWork = asyncWork
        }

        static func buildStep() -> Step {
            return Step.init { connection, completionHandler in
                var connection = connection
                print("build", connection.log)
                connection.log += "build"
                completionHandler(connection)
            }
        }

        func plugIn<P: Plug>(_ plug: @escaping () -> P) -> Step<C> where P.ConnectionType == C {
            // A stack of plugs needs to be executed from the bottom to the top.
            // To achieve that each step has to execute first the work of its
            // preceeding step.

            // Creating a step with work that is executed in the future.
            return Step(asyncWork: { connectionIn, completionHandler in
                // Before the new step executes its own work (executing the plug)
                // the work of the creator of the new step is executed.
                self.asyncWork(connectionIn) { connectionOut in
                    // After completing the preceding step's work the plug is executed.
                    plug().execute(connection: connectionOut) { connectionUpdated in
                        completionHandler(connectionUpdated)
                    }
                }
            })
        }

        func fire(_ connection: C) {
            self.asyncWork(connection, { connection in
                print("fired", connection.log)
            })
        }
    }

    static func build<C>() -> Step<C> {
        return Step.buildStep()
    }
}


struct APIService {

    static func requestThings() {
        let connection = MyConnnection()
        Torch.build()
            .plugIn(APICredentialsPlug.init)
            .plugIn(RequestPlug.init)
            .fire(connection)
    }
}


APIService.requestThings()
