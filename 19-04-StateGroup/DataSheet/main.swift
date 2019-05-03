//
//  main.swift
//  DataSheet
//
//  Created by Karsten Bruns on 31.03.19.
//  Copyright © 2019 bruns.me. All rights reserved.
//

import Foundation


protocol ExternalStateGroupProtocol: StateGroup {
  var apples: State<Int> { get }
  var appleJuice: State<Double> { get }
}


class ExternalStateGroup: StateGroup, ExternalStateGroupProtocol {
  lazy var apples = variable(2)
  lazy var appleJuice = map(apples) { Double($0) * 50 }
}


class MyStateGroup: StateGroup {
  lazy var pears = variable(2)
  lazy var sum = zip(externalStateGroup.apples, pears) { $0 + $1 }

  let externalStateGroup: ExternalStateGroupProtocol

  init(externalStateGroup: ExternalStateGroupProtocol) {
    self.externalStateGroup = externalStateGroup
    super.init()
  }
}


let observationPool = ObservationPool()
let externalStateGroup: ExternalStateGroupProtocol = ExternalStateGroup()
let myStateGroup = MyStateGroup(externalStateGroup: externalStateGroup)

myStateGroup.sum.observe { sum in
  print("Sum changed to: \(sum) (\(externalStateGroup.apples.value)+\(myStateGroup.pears.value))")
  print("AppleJuice: \(externalStateGroup.appleJuice.value) ml")
}.retain(in: observationPool)

myStateGroup.pears.value += 2
myStateGroup.externalStateGroup.apples.value = 9
