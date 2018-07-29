//
//  RetryPlug.swift
//  Connections
//
//  Created by Karsten Bruns on 29.07.18.
//  Copyright © 2018 Karsten Bruns. All rights reserved.
//

import Foundation


protocol RetryConnection: Connection {
    var attempts: Int { get set }
    var maxAttempts: Int { get }
}


struct RetryPlug<C>: Plug where C: RetryConnection {
    typealias ConnectionType = C

    static func evaluate(connection: C, callback: @escaping (C, PlugResult) -> ()) {
        var connection = connection
        connection.attempts += 1
        print("RetryPlug: a")
        callback(connection, connection.attempts <= connection.maxAttempts ? .success : .failure)
    }
}
