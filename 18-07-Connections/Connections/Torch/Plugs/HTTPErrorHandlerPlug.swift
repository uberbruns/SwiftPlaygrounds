//
//  HTTPErrorHandlerPlug.swift
//  Connections
//
//  Created by Karsten Bruns on 30.07.18.
//  Copyright © 2018 Karsten Bruns. All rights reserved.
//

import Foundation


protocol HTTPErrorHandlerConnection: HTTPRequestConnection {
}


struct HTTPErrorHandlerPlug<C>: Plug where C: HTTPErrorHandlerConnection {
    typealias ConnectionType = C

    static func run(with connection: C, callback: @escaping (C, PlugCommand) -> ()) {
        callback(connection, .progress)
    }
}
