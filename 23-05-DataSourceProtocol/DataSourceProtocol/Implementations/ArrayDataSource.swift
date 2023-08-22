final class ArrayDataSource<Item>: DataSource where Item: Identifiable {

  private let items: [Item]

  init(items: [Item]) {
    self.items = items
  }

  func get(id: Item.ID) -> Item? {
    items.first { $0.id == id }
  }

  func list() -> [Item.ID] {
    items.map(\.id)
  }
}


final class MutableArrayDataSource<Item>: DataSource, WritableDataSource where Item: Identifiable {

  private var items: [Item]

  init(items: [Item]) {
    self.items = items
  }

  func get(id: Item.ID) -> Item? {
    items.first { $0.id == id }
  }

  func list() -> [Item.ID] {
    items.map(\.id)
  }

  func delete(_ id: Item.ID) throws {
    guard let index = items.firstIndex(where: { $0.id == id }) else { return }
    items.remove(at: index)
  }

  func store(_ item: Item) throws {
    items.append(item)
  }
}
