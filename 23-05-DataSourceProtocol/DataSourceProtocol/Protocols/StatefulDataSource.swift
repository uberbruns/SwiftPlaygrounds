enum DataSourceState {
  case busy
  case ready
}


protocol StatefulDataSource: ThrowingDataSource {
  var state: DataSourceState { get }
}
