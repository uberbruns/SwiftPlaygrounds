//
//  URLRequestPlug.swift
//  Connections
//
//  Created by Karsten Bruns on 29.07.18.
//  Copyright © 2018 Karsten Bruns. All rights reserved.
//

import Foundation


protocol URLRequestConnection: Connection {
    var request: URLRequest { get set }
    var response: URLResponse? { get set }
    var error: Error? { get set }
    var data: Data? { get set }
}


struct URLRequestPlug<C>: Plug where C: URLRequestConnection {

    typealias ConnectionType = C

    init() { }

    func execute(connection: C, completion completionHandler: @escaping (C) -> ()) {
        let task = URLSession.shared.dataTask(with: connection.request) { (data, response, error) in
            var connection = connection
            connection.data = data
            connection.response = response
            connection.error = error
            completionHandler(connection)
        }
        task.resume()
    }
}
