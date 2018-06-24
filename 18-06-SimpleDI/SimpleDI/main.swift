//
//  main.swift
//  SimpleDI
//
//  Created by Karsten Bruns on 03.06.18.
//  Copyright © 2018 Karsten Bruns. All rights reserved.
//

import Foundation

// Complete Environment Definition

protocol PersistenceProvider { }

protocol HTTPRequestResolver { }

struct Environment {
  var httpRequestResolver: HTTPRequestResolver
  var persistenceProvider: PersistenceProvider
}

extension Environment: DataServiceEnvironment { }
extension Environment: WorkerEnvironment { }


// Class A defining own environment requirments

protocol DataServiceEnvironment {
  var httpRequestResolver: HTTPRequestResolver { get }
}


class DataService {
  init(env: DataServiceEnvironment) {

  }
}


// Class B defining own environment requirments

protocol WorkerEnvironment {
  var persistenceProvider: PersistenceProvider { get }
}


class Worker {
  init(env: WorkerEnvironment) {

  }
}
