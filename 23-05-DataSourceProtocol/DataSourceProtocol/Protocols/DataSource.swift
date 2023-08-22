import Foundation


typealias DataSourceItem = Identifiable


protocol AsyncThrowingDataSource<Item>: ObservableObject {
  associatedtype Item: DataSourceItem
  associatedtype List: Sequence<Item.ID>

  func get(id: Item.ID) async throws -> Item?
  func list() async throws -> List
}


protocol AsyncDataSource: AsyncThrowingDataSource {
  func get(id: Item.ID) async -> Item?
  func list() async -> List
}


protocol ThrowingDataSource: AsyncDataSource {
  func get(id: Item.ID) throws -> Item?
  func list() throws -> List
}


protocol DataSource: AsyncDataSource, ThrowingDataSource {
  func get(id: Item.ID) -> Item?
  func list() -> List
}
