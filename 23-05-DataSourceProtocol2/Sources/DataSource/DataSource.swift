import Foundation
import OrderedCollections


protocol DataItem: Identifiable { }


protocol DataSource<ID, Item>: ObservableObject {
  associatedtype Body

  associatedtype Item

  associatedtype ID

  var body: Body { get }

  var index: [ID] { get }

  func get(id: ID) -> Item?
}


extension DataSource where Body: DataSource<ID, Item>, Body.Item: DataItem, Item: DataItem {
  var index: [Body.ID] {
    body.index
  }

  func get(id: Body.ID) -> Body.Item? {
    body.get(id: id)
  }
}



extension DataSource where Body == Never {
  var body: Body {
    fatalError()
  }
}


final class InMemoryDataSource<Item: DataItem>: DataSource {

  typealias Item = Item
  typealias Body = Never

  private var storage: OrderedDictionary<Item.ID, Item>

  init(storage: OrderedDictionary<Item.ID, Item>) {
    self.storage = storage
  }

  init(_ sequence: some Sequence<Item>) {
    self.storage = sequence.reduce(into: [:], { $0[$1.id] = $1 })
  }

  var index: [Item.ID] {
    Array(storage.keys)
  }

  func get(id: Item.ID) -> Item? {
    storage[id]
  }
}


struct Crewman: DataItem {
  let id: String
  let name: String
}


struct Ship: DataItem {
  let id: String
  let `class`: String
  let crew: [Crewman]
}


final class ShipDataSource: DataSource {
  static let enterpriseOriginal = Ship(id: "1701", class: "Constitution", crew: [Crewman(id: "kirk", name: "Kirk"), Crewman(id: "spock", name: "Spock")])
  static let enterpriseD = Ship(id: "1701-D", class: "Galaxy", crew: [Crewman(id: "picard", name: "picard"), Crewman(id: "picard", name: "Picard")])
  static let ships = [enterpriseOriginal, enterpriseD]

  let body: some DataSource<String, Ship> = {
    InMemoryDataSource(ShipDataSource.ships)
  }()
}
