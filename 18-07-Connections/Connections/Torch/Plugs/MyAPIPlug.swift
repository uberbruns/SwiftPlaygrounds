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

    init() { }

    func progress(connection: C, nextPlug: @escaping (C, Bool) -> ()) {
        print("MyAPIPlug: a")
        nextPlug(connection, true)
    }
}
