protocol AsyncWritableDataSource: AsyncDataSource {
  func delete(_ id: Item.ID) async throws
  func store(_ item: Item) async throws
}


protocol WritableDataSource: AsyncWritableDataSource {
  func delete(_ id: Item.ID) throws
  func store(_ item: Item) throws
}
