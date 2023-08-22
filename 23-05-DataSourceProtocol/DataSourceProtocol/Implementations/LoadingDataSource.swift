import Foundation


final class PreloadingDataSource<WrappedDataSource>: StatefulDataSource where WrappedDataSource: AsyncDataSource {

  typealias Item = WrappedDataSource.Item
  typealias Items = Array<Item>
  typealias List = Array<Item.ID>

  private let dataSource: WrappedDataSource

  private(set) var state: DataSourceState {
    willSet {
      objectWillChange.send()
    }
  }

  private var items: Items {
    willSet {
      objectWillChange.send()
    }
  }

  init(dataSource: WrappedDataSource) {
    self.state = .busy
    self.dataSource = dataSource
    self.items = []
    Task {
      let list = await dataSource.list()
      var items = Items()
      for id in list {
        if let item = await dataSource.get(id: id) {
          items.append(item)
        }
      }
      self.items = items
      self.state = .ready
    }
  }

  func get(id: Item.ID) -> Item? {
    items.first { $0.id == id }
  }

  func list() -> List {
    items.map(\.id)
  }
}


extension AsyncDataSource {
  func preload() -> some ThrowingDataSource {
    return PreloadingDataSource(dataSource: self)
  }
}
