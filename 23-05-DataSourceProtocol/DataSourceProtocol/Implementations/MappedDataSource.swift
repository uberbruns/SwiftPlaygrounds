import Foundation


final class MappedDataSource<WrappedDataSource, MappedItem> where WrappedDataSource: AsyncThrowingDataSource, MappedItem: DataSourceItem {

  typealias WrappedItem = WrappedDataSource.Item

  typealias WrappedItemID = WrappedDataSource.Item.ID

  typealias MappedItemID = MappedItem.ID

  private let wrappedDataSource: WrappedDataSource

  private let map: (WrappedItem) -> MappedItem

  private let mapIDForward: (WrappedItemID) -> MappedItemID

  private let mapIDBackwards: (MappedItemID) -> WrappedItemID

  init(
    wrappedDataSource: WrappedDataSource,
    map: @escaping (WrappedItem) -> MappedItem,
    mapIDForward: @escaping (WrappedItemID) -> MappedItemID,
    mapIDBackwards: @escaping (MappedItemID) -> WrappedItemID
  ) {
    self.wrappedDataSource = wrappedDataSource
    self.map = map
    self.mapIDForward = mapIDForward
    self.mapIDBackwards = mapIDBackwards
  }
}


extension MappedDataSource: AsyncThrowingDataSource where WrappedDataSource: AsyncThrowingDataSource {
  func get(id: MappedItem.ID) async throws -> MappedItem? {
    let wrappedItemID = mapIDBackwards(id)
    guard let wrappedItem = try await wrappedDataSource.get(id: wrappedItemID) else {
      return nil
    }
    return map(wrappedItem)
  }

  func list() async throws -> [MappedItem.ID] {
    try await wrappedDataSource.list().map(mapIDForward)
  }
}


extension MappedDataSource: AsyncDataSource where WrappedDataSource: AsyncDataSource {
  func get(id: MappedItem.ID) async -> MappedItem? {
    let wrappedItemID = mapIDBackwards(id)
    guard let wrappedItem = await wrappedDataSource.get(id: wrappedItemID) else {
      return nil
    }
    return map(wrappedItem)
  }

  func list() async -> [MappedItem.ID] {
    await wrappedDataSource.list().map(mapIDForward)
  }
}


extension MappedDataSource: ThrowingDataSource where WrappedDataSource: ThrowingDataSource {
  func get(id: MappedItem.ID) throws -> MappedItem? {
    let wrappedItemID = mapIDBackwards(id)
    guard let wrappedItem = try wrappedDataSource.get(id: wrappedItemID) else {
      return nil
    }
    return map(wrappedItem)
  }

  func list() throws -> [MappedItem.ID] {
    try wrappedDataSource.list().map(mapIDForward)
  }
}


extension MappedDataSource: DataSource where WrappedDataSource: DataSource {
  func get(id: MappedItem.ID) -> MappedItem? {
    let wrappedItemID = mapIDBackwards(id)
    guard let wrappedItem = wrappedDataSource.get(id: wrappedItemID) else {
      return nil
    }
    return map(wrappedItem)
  }

  func list() -> [MappedItem.ID] {
    wrappedDataSource.list().map(mapIDForward)
  }
}


extension AsyncThrowingDataSource {
  func map<MappedItem: DataSourceItem>(_ map: @escaping (Item) -> MappedItem) -> some AsyncThrowingDataSource where MappedItem.ID == Item.ID {
    MappedDataSource(
      wrappedDataSource: self,
      map: map,
      mapIDForward: { $0 },
      mapIDBackwards: { $0 }
    )
  }
}
