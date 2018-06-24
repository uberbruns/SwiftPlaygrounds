//
//  FileTransferService.swift
//  SourceryPlayground
//
//  Created by Karsten Bruns on 24.06.18.
//  Copyright © 2018 Karsten Bruns. All rights reserved.
//

import Foundation


// sourcery:retro_protocol: name = "FileTransferServiceProtocol"
class FileTransferService {

  static let staticVars: Int = 0
  var instanceVar: Int = 0

  static func copy(data: Data, target: URL) throws -> Bool {
    return true
  }

  func move(source: URL, target: URL) throws -> Bool {
    return true
  }

  func hello() { }

  private func execute(cmd: String) { }
}
