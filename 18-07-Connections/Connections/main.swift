//
//  main.swift
//  Connections
//
//  Created by Karsten Bruns on 28.07.18.
//  Copyright © 2018 Karsten Bruns. All rights reserved.
//

import Foundation


struct MyService {

    struct Ipify: Codable {
        let ip: String
    }

    struct MyConnection: ResultDecoderConnection, URLRequestConnection, MyAPIConnection {

        typealias ResultType = Ipify

        let apiKey: String
        var request: URLRequest
        var response: URLResponse?
        var data: Data?
        var result: MyService.Ipify?
        var error: Error?

        init(url: URL) {
            self.apiKey = "123"
            self.request = URLRequest(url: url)
        }
    }

    static func requestIPAddress() {
        let connection = MyConnection(url: URL(string: "https://api.ipify.org/?format=json")!)
        Pipeline()
            .addPlug(MyAPIPlug.init)
            .addPlug(URLRequestPlug.init)
            .addPlug(ResultDecoderPlug.init)
            .load(connection) {
                dump($0.result)
                exit(0)
        }
    }
}


MyService.requestIPAddress()
RunLoop.main.run()
