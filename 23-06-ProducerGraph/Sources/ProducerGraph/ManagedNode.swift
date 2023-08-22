import Foundation


protocol ManagedNodeProtocol { }


class ManagedNode<N: Node>: ManagedNodeProtocol {

  let node: N
  let connection: Connection<N.Output>

  init(_ node: N) {
    self.node = node
    self.connection = node.connection
  }

  func callReceive(_ value: N.Input) {
    node.receive(value)
  }

  func connectToParent(_ inputConnection: Connection<N.Input>) {
    inputConnection.addReceive({ value in
      self.callReceive(value)
    })
  }

  func connectToParents<A, B>(_ inputConnectionA: Connection<A>, _ inputConnectionB: Connection<B>) where N.Input == (A, B) {
    var a: A? = nil
    var b: B? = nil

    let callMe = {
      guard let a, let b else { return }
      self.callReceive((a, b))
    }

    inputConnectionA.addReceive { newA in
      a = newA
      callMe()
    }

    inputConnectionB.addReceive { newB in
      b = newB
      callMe()
    }
  }
}
