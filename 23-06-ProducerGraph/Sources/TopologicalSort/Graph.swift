final class Graph {
  var edges = [GraphAlgorithm.Edge]()
  var managedNodes = [ManagedNode]()
  var topologicalSorting = [Int]()
  var outputs = [Any]()

  func addEdge(from source: ManagedNodeID, to destination: ManagedNodeID) {
    edges.append(
      GraphAlgorithm.Edge(source: source.rawValue, destination: destination.rawValue)
    )
  }

  func addManagedNode<N: Node>(_ node: N) -> ManagedNode {
    let newRawManageNodeID = (managedNodes.last?.identifier.rawValue).map({ $0 + 1 }) ?? 0
    let newManageNode = ManagedNode(node: node, identifier: ManagedNodeID(rawValue: newRawManageNodeID))
    managedNodes.append(newManageNode)
    outputs.append(node.output.initialValue)
    return newManageNode
  }

  init(_ setUpGraph: (Graph) -> Void) {
    setUpGraph(self)

    topologicalSorting = GraphAlgorithm(edges: edges, nodeCount: managedNodes.count).topologicalSorting()

    print(managedNodes)
    print(outputs)
    print(edges)
  }
}
