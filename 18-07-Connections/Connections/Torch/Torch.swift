//
//  Torch.swift
//  Connections
//
//  Created by Karsten Bruns on 29.07.18.
//  Copyright © 2018 Karsten Bruns. All rights reserved.
//

import Foundation


protocol Connection { }


enum PipelineCommand {
    case next
    case restart
    case abort
}


protocol Plug {
    associatedtype ConnectionType
    init()
    func evaluate(connection: ConnectionType, callback: @escaping (ConnectionType, PipelineCommand) -> ())
}


struct Pipeline<C: Connection> {

    typealias Work = (C, @escaping (C) -> Void) -> Void
    private let work: Work
    private let root: Bool

    private init(work: @escaping Work) {
        self.root = false
        self.work = work
    }

    init() {
        self.root = true
        self.work = { connection, completionHandler in
            completionHandler(connection)
        }
    }

    func addPlug<P: Plug>(_ plug: @escaping () -> P) -> Pipeline<C> where P.ConnectionType == C {
        // A stack of plugs needs to be executed from the bottom to the top.
        // To achieve that each new pipeline has to execute first the work of its
        // preceeding pipeline.
        let preceedingPipeline = self

        // Creating next pipeline.
        return Pipeline(work: { connectionIn, completionHandler in
            // Before the new pipeline can execute its own work (executing the plug)
            // the work of the preceeding pipeline is executed.
            func attempt(_ triedConnection: C) {
                preceedingPipeline.work(triedConnection) { connectionOut in
                    // After completing the preceding pipelines work the new plug is executed.
                    plug().evaluate(connection: connectionOut, callback: { connectionUpdated, command in
                        switch (command, preceedingPipeline.root) {
                        case (.next, _):
                            completionHandler(connectionUpdated)
                        case (.restart, false):
                            attempt(connectionUpdated)
                        default:
                            fatalError()
                        }
                    })
                }
            }
            attempt(connectionIn)
        })
    }

    func load(_ connection: C, queue: OperationQueue? = .main, completion finalCompletionHandler: @escaping (C) -> ()) {
        work(connection) { connection in
            if let queue = queue, queue != OperationQueue.current {
                queue.addOperation {
                    finalCompletionHandler(connection)
                }
            } else {
                finalCompletionHandler(connection)
            }
        }
    }
}
