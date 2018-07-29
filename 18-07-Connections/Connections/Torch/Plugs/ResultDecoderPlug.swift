//
//  ResultDecoderPlug.swift
//  Connections
//
//  Created by Karsten Bruns on 29.07.18.
//  Copyright © 2018 Karsten Bruns. All rights reserved.
//

import Foundation


protocol ResultDecoderConnection: URLRequestConnection {
    associatedtype ResultType: Decodable
    var decodedResult: ResultType? { get set }
}


struct ResultDecoderPlug<C>: Plug where C: ResultDecoderConnection {
    typealias ConnectionType = C

    init() { }

    func progress(connection: C, nextPlug: @escaping (C) -> ()) {
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
        nextPlug(connection)
    }
}
