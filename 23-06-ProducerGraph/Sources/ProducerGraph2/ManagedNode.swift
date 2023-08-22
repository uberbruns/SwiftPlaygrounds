final class ManagedNode<N: Node> {
  let node: N

  var nestedReceive: (N.Out) -> Void = { _  in }

  init(node: N) {
    self.node = node
  }
}
