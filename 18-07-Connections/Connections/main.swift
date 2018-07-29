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

    struct MyConnection<R: Decodable>: ResultDecoderConnection, URLRequestConnection, MyAPIConnection {

        typealias ResultType = R

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
        request(connection) { (connection) in
            dump(connection.decodedResult)
            exit(0)
        }
    }


    static func request<R: Decodable>(_ connection: MyConnection<R>, completion completionHandler: @escaping (MyConnection<R>) -> ()) {
        Pipeline()
            .addPlug(MyAPIPlug.init)
            .addPlug(URLRequestPlug.init)
            .addPlug(ResultDecoderPlug.init)
            .load(connection, completion: completionHandler)
    }

}


MyService.requestIPAddress()
RunLoop.main.run()
