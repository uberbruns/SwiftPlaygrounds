protocol SourceEdgeProtocol {
  associatedtype Out
  var graph: Graph { get }
  var sourceIdentifier: ManagedNodeID { get }
}


struct SourceEdge<Out>: SourceEdgeProtocol {
  let graph: Graph
  let sourceIdentifier: ManagedNodeID
}
