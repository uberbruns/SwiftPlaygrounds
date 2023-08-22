import Cocoa


protocol ManagedNodeProtocol { }


class ManagedNode<N: Node>: ManagedNodeProtocol {
  let node: N
  let connection: Connection<N.Outgoing>

  init(_ node: N) {
    self.node = node
    self.connection = Connection()
  }

  func send(_ value: N.Incoming) {
    node.receive(value)
  }
}


class Connection<Outgoing> {
  private var callReceivers: (Outgoing) -> Void = { _ in }

  private func updateCallback(_ newCallToReceiver: @escaping (Outgoing) -> Void) {
    let existingCallReceivers = callReceivers
    self.callReceivers = { out in
      existingCallReceivers(out)
      newCallToReceiver(out)
    }
  }

  func addEdge<N: Node>(to node: N) where N.Incoming == Outgoing {
    updateCallback { value in
      node.receive(value)
    }
  }

  func send(_ value: Outgoing) {
    callReceivers(value)
  }
}


protocol Node {
  associatedtype Incoming
  associatedtype Outgoing

  var connection: Connection<Outgoing> { get }

  func receive(_ incoming: Incoming) -> Void
}


extension Node {
  func callAsFunction(@NodeListBuilder _ makeConnections: (Connection<Outgoing>) -> Void = { _ in }) -> ManagedNode<Self> where Incoming == Void {
    print(self)
    let managedSelf = ManagedNode(self)
    makeConnections(managedSelf.connection)
    return managedSelf
  }

  func callAsFunction(_ incoming: Connection<Incoming>, @NodeListBuilder _ connectWith: (Connection<Outgoing>) -> Void = { _ in }) -> ManagedNode<Self> {
    print(self)
    let managedSelf = ManagedNode(self)
    incoming.addEdge(to: self)
    connectWith(managedSelf.connection)
    return managedSelf
  }

//  func callAsFunction<E1, E2>(_ connection1: Connection<E1>, _ connection2: Connection<E2>, @NodeListBuilder _ makeConnections: (Connection<Outgoing>) -> Void = { _ in }) -> Connection<Self> where Incoming == (E1, E2) {
//    makeConnections(Connection<Outgoing>())
//    return Connection()
//  }
}



@resultBuilder
struct NodeListBuilder {
  static func buildBlock(_ nodes: any ManagedNodeProtocol...) -> Void { }
}


@resultBuilder
struct GraphBuilder {
  static func buildBlock<N: Node>(_ managedNode: ManagedNode<N>) -> ManagedNode<N> {
    managedNode
  }
}


struct Graph<N: Node> where N.Incoming == Void {
  let rootNode: ManagedNode<N>

  init(@GraphBuilder _ graphBuilder: () -> ManagedNode<N>) {
    print("xxx")
    rootNode = graphBuilder()
    rootNode.send(())
  }
}





struct RootNode: Node {
  let connection = Connection<Int>()
  func receive(_ incoming: Void) {
    connection.send(1)
  }
}


struct FooNode: Node {
  let connection = Connection<String>()
  func receive(_ incoming: Int) {
    print(incoming)
  }
}


struct BarNode: Node {
  let connection = Connection<String>()
  func receive(_ incoming: Int) { }
}

struct Bar2Node: Node {
  let connection = Connection<String>()
  func receive(_ incoming: (Int, String)) { }
}



let a = RootNode()
let b = FooNode()
let c = BarNode()
let d = Bar2Node()

let g = Graph {
  a { a in
    b(a) { b in
      // c(a)
      // d(a, b)
    }
  }
}




