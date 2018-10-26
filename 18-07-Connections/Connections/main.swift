//
//  main.swift
//  Connections
//
//  Created by Karsten Bruns on 28.07.18.
//  Copyright © 2018 Karsten Bruns. All rights reserved.
//

import Foundation


struct MyService {

    struct IpifyResult: Codable {
        let ip: String
    }

    struct MyConnection<R: Decodable>:
        JSONDecoderConnection,
        HTTPRequestConnection,
        HTTPErrorHandlerConnection,
        MyAPIConnection,
        RetryConnection {

        typealias ResultType = R

        var attempts = 0
        let maxAttempts = 5
        let apiKey: String

        var request: URLRequest
        var response: URLResponse?
        var data: Data?
        var decodedResult: R?
        var error: Error?

        init(url: URL) {
            self.apiKey = "123"
            self.request = URLRequest(url: url)
        }
    }
    

    static func requestIPAddress() {
        let connection = MyConnection<IpifyResult>(url: URL(string: "https://api.ipify.org/?format=json")!)
        request(connection) { connection, finished in
            dump(connection.decodedResult)
            exit(finished ? 0 : 1)
        }
    }


    static func request<R: Decodable>(_ connection: MyConnection<R>, completion completionHandler: @escaping (MyConnection<R>, Bool) -> ()) {
        let pipeline = Pipeline<MyConnection<R>>()
            .append(RetryPlug.self)
            .append(MyAPIPlug.self)
            .append(HTTPRequestPlug.self, allowRestart: true)
            .append(HTTPErrorHandlerPlug.self, allowRestart: true)
            .append(JSONDecoderPlug.self)

        pipeline.load(connection, completion: completionHandler)
    }
}


MyService.requestIPAddress()
RunLoop.main.run()
