//
//  ResultDecoderPlug.swift
//  Connections
//
//  Created by Karsten Bruns on 29.07.18.
//  Copyright © 2018 Karsten Bruns. All rights reserved.
//

import Foundation


protocol JSONDecoderConnection: HTTPRequestConnection {
    associatedtype ResultType: Decodable
    var decodedResult: ResultType? { get set }
}


struct JSONDecoderPlug<C>: Plug where C: JSONDecoderConnection {
    typealias ConnectionType = C

    static func run(with connection: C, callback: @escaping (C, PlugCommand) -> ()) {
        var connection = connection
        let work = {
            guard let data = connection.data else { return }
            connection.decodedResult = try? JSONDecoder().decode(C.ResultType.self, from: data)
        }
        if OperationQueue.current == .main {
            OperationQueue().addOperation {
                work()
            }
        } else {
            work()
        }
        callback(connection, .progress)
    }
}
