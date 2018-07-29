//
//  Torch.swift
//  Connections
//
//  Created by Karsten Bruns on 29.07.18.
//  Copyright © 2018 Karsten Bruns. All rights reserved.
//

import Foundation


protocol Connection { }


enum PlugResult {
    case success
    case failure
}


enum PlugFailureStrategy {
    case restartPipeline
    case stopPipeline
}


protocol Plug {
    associatedtype ConnectionType
    static func evaluate(connection: ConnectionType, callback: @escaping (ConnectionType, PlugResult) -> ())
}


struct Pipeline<C: Connection> {

    typealias Work = (C, @escaping (C, Bool) -> Void) -> Void
    private let work: Work
    private let root: Bool

    private init(work: @escaping Work) {
        self.root = false
        self.work = work
    }

    init() {
        self.root = true
        self.work = { connection, completionHandler in
            completionHandler(connection, true)
        }
    }

    func append<P: Plug>(_ plug: P.Type, onFailure failureStrategy: PlugFailureStrategy = .stopPipeline) -> Pipeline<C> where P.ConnectionType == C {
        // A stack of plugs needs to be executed from the bottom to the top.
        // To achieve that each new pipeline has to execute first the work of its
        // preceeding pipeline.
        let preceedingPipeline = self

        // Creating next pipeline.
        return Pipeline(work: { connectionIn, completionHandler in
            // To make work repeatable this step is capsuled in a function.
            func executeWork(_ triedConnection: C) {

                // Before the new pipeline can execute its own work (executing the plug)
                // the work of the preceeding pipeline is executed.
                preceedingPipeline.work(triedConnection, { connectionOut, isProgressing in
                    // The work of the preceeding pipeline is done. If we stopped progressing
                    // we directly call the completion handler to go back to the  beginning of
                    // the stack.
                    guard isProgressing else {
                        completionHandler(connectionOut, false)
                        return
                    }

                    // After completing the preceding pipelines work the new plug's connection
                    // evaluation executed.
                    plug.evaluate(connection: connectionOut, callback: { connectionUpdated, plugResult in

                        // Depending on the plug result and configuration, we
                        // - call the completion handler with success `true` or
                        // - call the completion handler with success `false` or
                        // - or attempt a restart
                        switch (plugResult, failureStrategy, preceedingPipeline.root) {
                        case (.success, _, _):
                            completionHandler(connectionUpdated, true)
                        case (.failure, .restartPipeline, false):
                            executeWork(connectionUpdated)
                        default:
                            completionHandler(connectionUpdated, false)
                        }
                    })
                })
            }
            executeWork(connectionIn)
        })
    }

    func load(_ connection: C, queue: OperationQueue? = .main, completion finalCompletionHandler: @escaping (C, Bool) -> ()) {
        work(connection) { connection, finished  in
            if let queue = queue, queue != OperationQueue.current {
                queue.addOperation {
                    finalCompletionHandler(connection, finished)
                }
            } else {
                finalCompletionHandler(connection, finished)
            }
        }
    }
}
