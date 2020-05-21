//
//  Map.swift
//  Map
//
//  Created by Karsten Bruns on 27.08.19.
//  Copyright © 2019 bruns.me. All rights reserved.
//

import Foundation


struct Map<K: CaseIterable & Hashable, V> {
  fileprivate var allKeys: [K]
  fileprivate var storage: [K: V]
  fileprivate var defaultValue: V
  fileprivate var current = 0

  init(keys: K.Type, default defaultValue: V) {
    self.allKeys = Array(K.allCases)
    self.storage = Dictionary(minimumCapacity: allKeys.count)
    self.defaultValue = defaultValue
  }

  subscript(_ key: K) ->  V {
    get {
      return storage[key, default: defaultValue]
    }
    set {
      storage[key] = newValue
    }
  }
}


extension Map: CustomDebugStringConvertible {
  var debugDescription: String {
    return storage.debugDescription
  }
}


extension Map: Sequence, IteratorProtocol {
  typealias Element = (K, V)

  mutating func next() -> (K, V)? {
    guard current < allKeys.count else { return nil }
    defer {
      current += 1
    }

    return (allKeys[current], self[allKeys[current]])
  }
}


extension Map: Collection {
  typealias Index = K.AllCases.Index

  var startIndex: K.AllCases.Index {
    return K.allCases.startIndex
  }

  var endIndex: K.AllCases.Index {
    return K.allCases.endIndex
  }

  func index(after i: K.AllCases.Index) -> K.AllCases.Index {
    return K.allCases.index(after: i)
  }

  subscript(position: K.AllCases.Index) -> (K, V) {
    get {
      let key = K.allCases[position]
      return (key, self[key])
    }
  }
}
