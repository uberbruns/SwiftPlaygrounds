import Foundation


final class DataSourceView<ParentDataSource, TargetItem, TargetList: Sequence<TargetItem>> where ParentDataSource: AsyncThrowingDataSource, TargetItem: DataSourceItem {

  typealias Item = TargetItem
  typealias Items = Array<TargetItem>
  typealias List = Array<TargetItem.ID>

  private let parentDataSource: ParentDataSource
  private let keyPath: KeyPath<ParentDataSource.Item, TargetList>
  private let parentItemID: ParentDataSource.Item.ID

  init(
    parentItemID: ParentDataSource.Item.ID,
    parentDataSource: ParentDataSource,
    keyPath: KeyPath<ParentDataSource.Item, TargetList>
  ) {
    self.parentItemID = parentItemID
    self.parentDataSource = parentDataSource
    self.keyPath = keyPath
  }

  private func list(parentItem: ParentDataSource.Item) -> List {
    let parentItemList = parentItem[keyPath: keyPath]
    return parentItemList.map(\.id)
  }

  private func get(id: Item.ID, parentItem: ParentDataSource.Item) -> Item? {
    let parentItemList = parentItem[keyPath: keyPath]
    return parentItemList.first { $0.id == id }
  }
}


extension DataSourceView: AsyncThrowingDataSource {
  func list() async throws -> List {
    guard let parentItem = try await parentDataSource.get(id: parentItemID) else {
      return []
    }
    return list(parentItem: parentItem)
  }

  func get(id: Item.ID) async throws -> Item? {
    guard let parentItem = try await parentDataSource.get(id: parentItemID) else {
      return nil
    }
    return get(id: id, parentItem: parentItem)
  }
}


extension DataSourceView: AsyncDataSource where ParentDataSource: AsyncDataSource {
  func list() async -> List {
    guard let parentItem = await parentDataSource.get(id: parentItemID) else {
      return []
    }
    return list(parentItem: parentItem)
  }

  func get(id: Item.ID) async -> Item? {
    guard let parentItem = await parentDataSource.get(id: parentItemID) else {
      return nil
    }
    return get(id: id, parentItem: parentItem)
  }
}


extension DataSourceView: ThrowingDataSource where ParentDataSource: ThrowingDataSource {
  func list() throws -> List {
    guard let parentItem = try parentDataSource.get(id: parentItemID) else {
      return []
    }
    return list(parentItem: parentItem)
  }

  func get(id: Item.ID) throws -> Item? {
    guard let parentItem = try parentDataSource.get(id: parentItemID) else {
      return nil
    }
    return get(id: id, parentItem: parentItem)
  }
}


extension DataSourceView: DataSource where ParentDataSource: DataSource {
  func list() -> List {
    guard let parentItem = parentDataSource.get(id: parentItemID) else {
      return []
    }
    return list(parentItem: parentItem)
  }

  func get(id: Item.ID) -> Item? {
    guard let parentItem = parentDataSource.get(id: parentItemID) else {
      return nil
    }
    return get(id: id, parentItem: parentItem)
  }
}


extension AsyncThrowingDataSource {
  func source<TargetItem: DataSourceItem, TargetList: Sequence<TargetItem>>(
    for keyPath: KeyPath<Self.Item, TargetList>,
    of parentItemID: Self.Item.ID
  ) -> some AsyncThrowingDataSource<TargetItem> {
    return DataSourceView(parentItemID: parentItemID, parentDataSource: self, keyPath: keyPath)
  }
}
