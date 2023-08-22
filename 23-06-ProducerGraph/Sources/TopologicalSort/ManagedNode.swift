struct ManagedNodeID: RawRepresentable {
  let rawValue: Int
}


final class ManagedNode {
  let node: any Node
  let identifier: ManagedNodeID

  init<N: Node>(node: N, identifier: ManagedNodeID) {
    self.node = node
    self.identifier = identifier
  }
}
