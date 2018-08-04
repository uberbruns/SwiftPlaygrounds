//
//  HTTPRequestPlug.swift
//  Connections
//
//  Created by Karsten Bruns on 29.07.18.
//  Copyright © 2018 Karsten Bruns. All rights reserved.
//

import Foundation


protocol HTTPRequestConnection: Connection {
    var request: URLRequest { get set }
    var response: URLResponse? { get set }
    var error: Error? { get set }
    var data: Data? { get set }
}


struct HTTPRequestPlug<C>: Plug where C: HTTPRequestConnection & RetryConnection {

    typealias ConnectionType = C

    static func run(with connection: C, callback: @escaping (C, PlugCommand) -> ()) {
        let task = URLSession.shared.dataTask(with: connection.request) { (data, response, error) in
            var connection = connection
            connection.data = data
            connection.response = response
            connection.error = error
            callback(connection, .progress)
        }
        task.resume()
    }
}
