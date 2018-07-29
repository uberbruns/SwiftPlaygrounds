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
    func execute(connection: ConnectionType, completion completionHandler: @escaping (ConnectionType) -> ())
}


struct Pipeline<C: Connection> {

    typealias Work = (C, @escaping (C) -> Void) -> Void
    private let work: Work

    private init(work: @escaping Work) {
        self.work = work
    }

    init() {
        self = .init(work: { connection, completionHandler in
            completionHandler(connection)
        })
    }

    func addPlug<P: Plug>(_ plug: @escaping () -> P) -> Pipeline<C> where P.ConnectionType == C {
        // A stack of plugs needs to be executed from the bottom to the top.
        // To achieve that each new pipeline has to execute first the work of its
        // preceeding pipeline.
        let preceedingHandler = self

        // Creating next pipeline.
        return Pipeline(work: { connectionIn, completionHandler in
            // Before the new pipeline executes its own work (executing the plug)
            // the work of the parent/preceeding pipeline is executed.
            preceedingHandler.work(connectionIn) { connectionOut in
                // After completing the preceding pipelines work the new plug is executed.
                plug().execute(connection: connectionOut) { connectionUpdated in
                    completionHandler(connectionUpdated)
                }
            }
        })
    }

    func load(_ connection: C, queue: OperationQueue? = .main, completion finalCompletionHandler: @escaping (C) -> ()) {
        self.work(connection) { connection in
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
