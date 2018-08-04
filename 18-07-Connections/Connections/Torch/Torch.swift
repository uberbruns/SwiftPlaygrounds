//
//  Torch.swift
//  Connections
//
//  Created by Karsten Bruns on 29.07.18.
//  Copyright © 2018 Karsten Bruns. All rights reserved.
//

import Foundation


protocol Connection { }


enum PlugCommand {
    case progress
    case restarOrAbort
    case abort
}


protocol Plug {
    associatedtype ConnectionType
    static func run(with connection: ConnectionType, callback: @escaping (ConnectionType, PlugCommand) -> ())
}


struct Pipeline<C: Connection> {

    typealias Work = (C, @escaping (C, Bool) -> Void) -> Void
    private let work: Work
    private let isRoot: Bool

    private init(work: @escaping Work) {
        self.isRoot = false
        self.work = work
    }

    init() {
        self.isRoot = true
        self.work = { connection, completionHandler in
            completionHandler(connection, true)
        }
    }

    func append<P: Plug>(_ plug: P.Type, allowRestart: Bool = false) -> Pipeline<C> where P.ConnectionType == C {
        // A stack of plugs needs to be executed from the bottom to the top.
        // To achieve that each new pipeline has to execute first the work of its
        // preceeding pipeline.
        let preceedingPipeline = self

        // Creating next pipeline.
        return Pipeline(work: { connection, completionHandler in
            // To make work repeatable this step is capsuled in a function.
            func runPlug(_ connectionIn: C) {

                // Before the new pipeline can execute its own work (executing the plug)
                // the work of the preceeding pipeline is executed.
                preceedingPipeline.work(connectionIn, { connectionOut, isProgressing in
                    // The work of the preceeding pipeline is done. If we stopped progressing
                    // we directly call this pipelines completion handler to go back to the beginning
                    //  of the stack.
                    guard isProgressing else {
                        completionHandler(connectionOut, false)
                        return
                    }

                    // After completing the preceeding pipelines work the new plug's connection
                    // evaluation executed.
                    plug.run(with: connectionOut, callback: { updatedConnection, plugResult in

                        // Depending on the plug result and configuration, we
                        // - call the completion handler with success `true` or
                        // - call the completion handler with success `false` or
                        // - attempt a restart of the pipeline.
                        switch (plugResult, allowRestart, preceedingPipeline.isRoot) {
                        case (.progress, _, _):
                            completionHandler(updatedConnection, true)
                        case (.restarOrAbort, true, false):
                            runPlug(updatedConnection)
                        default:
                            completionHandler(updatedConnection, false)
                        }
                    })
                })
            }
            runPlug(connection)
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
