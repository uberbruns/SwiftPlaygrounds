


@main
public struct Main {
  public static func main() {
//    // List of graph edges as per the above diagram
//    let edges: [GraphAlgorithm.Edge] = [
//      .init(source: 0, destination: 6), .init(source: 1, destination: 2), .init(source: 1, destination: 4),
//      .init(source: 1, destination: 6), .init(source: 3, destination: 0), .init(source: 3, destination: 4),
//      .init(source: 5, destination: 1), .init(source: 7, destination: 0), .init(source: 7, destination: 1)
//    ]
//
//    // Total number of nodes in the graph (labelled from 0 to 7)
//    let nodeCount = 8
//
//    // Build a graph from the given edges
//    let graph = GraphAlgorithm(edges: edges, nodeCount: nodeCount);
//
//    // Perform topological sort
//    let sorting = graph.topologicalSorting()
//    print(sorting)
//
//
//    /*
//     Graph {
//       let a = ProducerA().connect()
//       let b = ProducerB().connect(a).publish(to: &self.b)
//       let c = ProducerB().connect(a, b.foo)
//     }
//     */

    let producerA = ProducerA()
    let producerB = ProducerB()

    let graph = Graph { graph in
      producerA.setUp(graph: graph) { a in
        producerB.setUp(sourceEdge: a) { b in

        }
      }
    }
  }
}


class ProducerA: Node {
  var output = Output(initialValue: 0)
  func process(input: Void) {
    send(1)
  }
}


class ProducerB: Node {
  var output = Output<String?>(initialValue: nil)
  func process(input: Int) {
    send("Hello \(input)!")
  }
}
