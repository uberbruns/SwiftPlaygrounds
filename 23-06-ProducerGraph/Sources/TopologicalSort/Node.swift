protocol Node<In, Out> {
  associatedtype In
  associatedtype Out

  var output: Output<Out> { get }
  func process(input: In)
}



final class Output<Out> {

  let initialValue: Out

  var send: ((Out) -> Void)?

  init(initialValue: Out) {
    self.initialValue = initialValue
  }
}


extension Node {
  func send(_ value: Out) {
    output.send?(value)
  }
}



// MARK: - Upstream Edges: One

extension Node {
  @discardableResult
  func setUp(graph: Graph, setUpDestinationNodes: (SourceEdge<Out>) -> Void) -> ManagedNode {
    let managedSelf = graph.addManagedNode(self)
    let destinationEdgeBuilder = SourceEdge<Out>(graph: graph, sourceIdentifier: managedSelf.identifier)
    setUpDestinationNodes(destinationEdgeBuilder)
    return managedSelf
  }

  @discardableResult
  func setUp<E: SourceEdgeProtocol>(sourceEdge: E, setUpDestinationNodes: (SourceEdge<Out>) -> Void) -> ManagedNode where E.Out == In {
    let graph = sourceEdge.graph
    let managedSelf = graph.addManagedNode(self)
    graph.addEdge(from: sourceEdge.sourceIdentifier, to: managedSelf.identifier)
    let destinationEdgeBuilder = SourceEdge<Out>(graph: graph, sourceIdentifier: managedSelf.identifier)
    setUpDestinationNodes(destinationEdgeBuilder)
    return managedSelf
  }
}
