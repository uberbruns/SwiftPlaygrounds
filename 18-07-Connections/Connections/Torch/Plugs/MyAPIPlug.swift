//
//  MyAPIPlug.swift
//  Connections
//
//  Created by Karsten Bruns on 29.07.18.
//  Copyright © 2018 Karsten Bruns. All rights reserved.
//

import Foundation


protocol MyAPIConnection: HTTPRequestConnection {
    var apiKey: String { get }
}


struct MyAPIPlug<C>: Plug where C: MyAPIConnection {
    typealias ConnectionType = C

    static func run(with connection: C, callback: @escaping (C, PlugCommand) -> ()) {
        var connection = connection
        connection.request.addValue("application/json", forHTTPHeaderField: "Accept")
        connection.request.addValue(connection.apiKey, forHTTPHeaderField: "X-MYAPI-KEY")
        callback(connection, .progress)
    }
}
