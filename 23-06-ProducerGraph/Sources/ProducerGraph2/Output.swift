final class Output<Out> {
  var send: ((Out) -> Void)?

  init(_ type: Out.Type = Out.Type) { }
}


extension Node {
  func send(_ value: Out) {
    output.send?(value)
  }
}
