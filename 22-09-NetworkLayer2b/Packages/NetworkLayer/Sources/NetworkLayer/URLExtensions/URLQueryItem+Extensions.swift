import Foundation


public extension Array where Element == URLQueryItem {
  subscript(name: String) -> String? {
    get {
      first(where: { $0.name == name })?.value
    }
    set {
      var queryItems = self
      queryItems[name] = newValue.map { [$0] } ?? []
      self = queryItems
    }
  }

  subscript(name: String) -> [String] {
    get {
      filter({ $0.name == name }).compactMap(\.value)
    }
    set {
      var newValues = newValue
      var obsoleteIndices = IndexSet()
      for index in indices where self[index].name == name {
        if !newValues.isEmpty {
          self[index].value = newValues.removeFirst()
        } else {
          obsoleteIndices.insert(index)
        }
      }
      for obsoleteIndex in obsoleteIndices.sorted().reversed() {
        remove(at: obsoleteIndex)
      }
      for newValue in newValues {
        append(URLQueryItem(name: name, value: newValue))
      }
    }
  }
}


public extension Optional where Wrapped == [URLQueryItem] {
  subscript(name: String) -> String? {
    get {
      guard case .some(let queryItems) = self else { return nil }
      return queryItems[name]
    }
    set {
      var queryItems = self ?? [URLQueryItem]()
      queryItems[name] = newValue
      self = queryItems
    }
  }

  subscript(name: String) -> [String] {
    get {
      guard case .some(let queryItems) = self else { return [] }
      return queryItems[name]
    }
    set {
      var queryItems = self ?? [URLQueryItem]()
      queryItems[name] = newValue
      self = queryItems
    }
  }
}
