import Foundation


protocol Node: AnyObject {
  associatedtype Input
  associatedtype Output

  var connection: Connection<Output> { get }

  func receive(_ input: Input) -> Void
}


extension Node {
  func callAsFunction(
    @NodeListBuilder _ connectToChildren: (Connection<Output>) -> Void = { _ in }
  ) -> ManagedNode<Self> where Input == Void {
    let managedSelf = ManagedNode(self)
    connectToChildren(managedSelf.connection)
    return managedSelf
  }

  func callAsFunction(
    _ input: Connection<Input>,
    @NodeListBuilder _ connectToChildren: (Connection<Output>) -> Void = { _ in }
  ) -> ManagedNode<Self> {
    let managedSelf = ManagedNode(self)
    managedSelf.connectToParent(input)
    connectToChildren(managedSelf.connection)
    return managedSelf
  }

  func callAsFunction(
    _ input: Connection<Input>,
    assignTo: inout Output,
    @NodeListBuilder _ connectToChildren: (Connection<Output>) -> Void = { _ in }
  ) -> ManagedNode<Self> {
    let managedSelf = ManagedNode(self)
    managedSelf.connectToParent(input)
    connectToChildren(managedSelf.connection)
    return managedSelf
  }

  func callAsFunction<A, B>(
    _ inputA: Connection<A>,
    _ inputB: Connection<B>,
    @NodeListBuilder _ connectToChildren: (Connection<Output>) -> Void = { _ in }
  ) -> ManagedNode<Self> where Self.Input == (A, B) {
    let managedSelf = ManagedNode(self)
    managedSelf.connectToParents(inputA, inputB)
    connectToChildren(managedSelf.connection)
    return managedSelf
  }

  func send(_ value: Output) {
    self.connection.send(value)
  }
}


@resultBuilder
struct NodeListBuilder {
  static func buildBlock(_ nodes: any ManagedNodeProtocol...) -> Void { }
}
