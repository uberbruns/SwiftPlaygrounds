import Foundation


/// A class to represent a graph object
/// Ported from: https://www.techiedelight.com/topological-sorting-dag/
struct GraphAlgorithm {
  /// A list of lists to represent an adjacency list
  let adjacencyList: [[Int]]

  var nodeCount: Int {
    adjacencyList.count
  }

  /// Constructor
  init(edges: [Edge], nodeCount: Int) {
    // Allocate memory
    var adjacencyList = Array<[Int]>(repeating: [], count: nodeCount)

    // Add edges to the directed graph
    for edge in edges {
      // Add an edge from source to destination
      adjacencyList[edge.source].append(edge.destination)
    }

    self.adjacencyList = adjacencyList
  }
}


extension GraphAlgorithm {
  /// A class to store a graph edge
  struct Edge {
    let source: Int
    let destination: Int

    init(source: Int, destination: Int) {
      self.source = source
      self.destination = destination
    }
  }

}


extension GraphAlgorithm {
  /// Perform depth-first-search on the graph and set the departure time of all
  /// nodes of the graph
  private func depthFirstSearch(node v: Int, discovered: inout [Bool], departure: inout [Int], time: Int) -> Int {
    // Mark the current node as discovered
    discovered[v] = true

    // Set the arrival time of node `v`
    var time = time + 1

    // Do for every edge (v, u) where `u` is not yet discovered
    for u in adjacencyList[v] where !discovered[u] {
      time = depthFirstSearch(
        node: u,
        discovered: &discovered,
        departure: &departure,
        time: time
      )
    }

    // Ready to backtrack
    // Set departure time of node `v`
    departure[time] = v
    time += 1

    return time
  }

  /// Function to perform a topological sort on a given DAG
  func topologicalSorting() -> [Int] {
    // `departure` stores the node number using departure time as an index.
    var departure = Array(repeating: -1, count: 2 * nodeCount)

    // If we had done it the other way around, i.e., fill the array
    // with departure time using node number as an index, we would
    // need to sort it later.

    // To keep track of whether a node is discovered or not.
    var discovered = Array(repeating: false, count: nodeCount)
    var time = 0

    // Perform depth-first-search on all undiscovered nodes.
    for node in 0 ..< nodeCount where !discovered[node] {
      time = depthFirstSearch(
        node: node,
        discovered: &discovered,
        departure: &departure,
        time: time
      )
    }

    // Return the nodes with decreasing departure time in depth-first-search as topological order.
    var sortedNodes = [Int]()
    for i in (0 ..< 2 * nodeCount).reversed() where departure[i] != -1 {
      sortedNodes.append(departure[i])
    }
    return sortedNodes
  }
}
