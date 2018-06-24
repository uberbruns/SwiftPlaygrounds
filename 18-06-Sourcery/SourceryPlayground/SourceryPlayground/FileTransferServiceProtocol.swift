//
//  FileTransferService.swift
//  SourceryPlayground
//
//  Created by Karsten Bruns on 24.06.18.
//  Copyright © 2018 Karsten Bruns. All rights reserved.
//

import Foundation

// sourcery:inline:FileTransferService.RetroProtocol

protocol FileTransferServiceProtocol {
    static var staticVars: Int { get }
    var instanceVar: Int { get set }
    static func copy(data: Data, target: URL) throws -> Bool
    func move(source: URL, target: URL) throws -> Bool
    func hello()
}

extension FileTransferService: FileTransferServiceProtocol { }

// sourcery:end
