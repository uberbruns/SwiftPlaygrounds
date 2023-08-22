import Foundation


private enum ConnectionValues {
  @TaskLocal
  static var isRecursiveInvocation = false
}


final class Edges<Output> {
  var call: (Output) -> Void = { _ in }
}


protocol ConnectionProtocol {
  associatedtype Output

  var edges: Edges<Output> { get }

  func addReceive(_ newSenderCallback: @escaping (Output) -> Void)

  func send(_ value: Output)
}


struct Connection<Output>: ConnectionProtocol {

  let edges = Edges<Output>()

  weak var graph: Graph?

  func addReceive(_ newSenderCallback: @escaping (Output) -> Void) {
    let existingSenderCallback = self.edges.call
    self.edges.call = { outputValue in
      existingSenderCallback(outputValue)
      newSenderCallback(outputValue)
    }
  }

  func send(_ value: Output) {
    if ConnectionValues.isRecursiveInvocation {
      edges.call(value)
    } else {
      ConnectionValues.$isRecursiveInvocation.withValue(true) {
        edges.call(value)
        print("Done")
      }
    }
  }
}


extension Connection {

}
