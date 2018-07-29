//
//  MyAPIPlug.swift
//  Connections
//
//  Created by Karsten Bruns on 29.07.18.
//  Copyright © 2018 Karsten Bruns. All rights reserved.
//

import Foundation


protocol MyAPIConnection: Connection {
    var apiKey: String { get }
}


struct MyAPIPlug<C>: Plug where C: MyAPIConnection {
    typealias ConnectionType = C

    static func evaluate(connection: C, callback: @escaping (C, PlugResult) -> ()) {
        print("MyAPIPlug: a")
        callback(connection, .success)
    }
}
