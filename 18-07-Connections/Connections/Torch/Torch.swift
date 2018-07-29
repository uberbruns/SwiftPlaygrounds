//
//  Torch.swift
//  Connections
//
//  Created by Karsten Bruns on 29.07.18.
//  Copyright © 2018 Karsten Bruns. All rights reserved.
//

import Foundation


protocol Connection { }


protocol Plug {
    associatedtype ConnectionType
    init()
    func progress(connection: ConnectionType, nextPlug: @escaping (ConnectionType, Bool) -> ())
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
                    plug().progress(connection: connectionOut, nextPlug: { connectionUpdated, success in
                        if success {
                            completionHandler(connectionUpdated)
                        } else {
                            if !preceedingPipeline.root {
                                attempt(connectionUpdated)
                            } else {
                                fatalError()
                            }
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
