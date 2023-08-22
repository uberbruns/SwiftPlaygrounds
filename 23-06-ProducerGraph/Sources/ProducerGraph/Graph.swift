import Foundation


@resultBuilder
struct GraphBuilder {
  static func buildBlock<N: Node>(_ managedNode: ManagedNode<N>) -> ManagedNode<N> {
    managedNode
  }
}


final class Graph {
  private let rootNode: Any?

  init<N: Node>(@GraphBuilder _ graphBuilder: () -> ManagedNode<N>) where N.Input == Void {
    let rootNode = graphBuilder()
    rootNode.callReceive(())
    self.rootNode = rootNode
  }

  func addProductOutlet<Output>(_ productOutlet: ProductOutlet<Output>) {

  }
}
