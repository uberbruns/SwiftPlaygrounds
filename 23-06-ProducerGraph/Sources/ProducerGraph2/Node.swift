protocol Node {
  associatedtype In
  associatedtype Out

  var output: Output<Out> { get }
  func process(input: In)
}


// MARK: - Upstream Edges: None

extension Node {
  @discardableResult
  func callAsFunction(setUpDownstreamNodes: (Edge<Out>) -> Void) -> ManagedNode<Self> {
    setUp(setUpDownstreamNodes: setUpDownstreamNodes)
  }

  @discardableResult
  func setUp(setUpDownstreamNodes: (Edge<Out>) -> Void) -> ManagedNode<Self> {
    let managedSelf = ManagedNode(node: self)

    output.send = { output in
      managedSelf.nestedReceive(output)
    }

    let downstreamEdge = Edge<Out>(
      addReceive: { newReceiver in
        let previousNestedReceive = managedSelf.nestedReceive
        managedSelf.nestedReceive = { output in
          previousNestedReceive(output)
          newReceiver(output)
        }
      }
    )

    setUpDownstreamNodes(downstreamEdge)
    return managedSelf
  }
}


// MARK: - Upstream Edges: One

extension Node {
  @discardableResult
  func callAsFunction<E: Edgy>(_ upstreamEdge: E, setUpDownstreamNodes: (Edge<Out>) -> Void) -> ManagedNode<Self> where E.Out == In {
    setUp(upstreamEdge: upstreamEdge, setUpDownstreamNodes: setUpDownstreamNodes)
  }

  @discardableResult
  func setUp<E: Edgy>(upstreamEdge: E, setUpDownstreamNodes: (Edge<Out>) -> Void) -> ManagedNode<Self> where E.Out == In {
    let managedSelf = setUp(setUpDownstreamNodes: setUpDownstreamNodes)
    upstreamEdge.addReceive { input in
      process(input: input)
    }
    return managedSelf
  }
}


// MARK: - Upstream Edges: Two

extension Node {
  @discardableResult
  func callAsFunction<In1, In2, E1: Edgy, E2: Edgy>(
    _ upstreamEdge1: E1,
    _ upstreamEdge2: E2,
    setUpDownstreamNodes: (Edge<Out>) -> Void = { _ in }
  ) -> ManagedNode<Self> where In == (In1, In2), E1.Out == In1, E2.Out == In2 {
    setUp(upstreamEdge1, upstreamEdge2, setUpDownstreamNodes: setUpDownstreamNodes)
  }

  @discardableResult
  func setUp<In1, In2, E1: Edgy, E2: Edgy>(
    _ upstreamEdge1: E1,
    _ upstreamEdge2: E2,
    setUpDownstreamNodes: (Edge<Out>) -> Void
  ) -> ManagedNode<Self> where In == (In1, In2), E1.Out == In1, E2.Out == In2 {
    let managedSelf = setUp(setUpDownstreamNodes: setUpDownstreamNodes)

    var latest1: In1?
    var latest2: In2?
    let callProcess = {
      guard let latest1, let latest2 else { return }
      process(input: (latest1, latest2))
    }

    upstreamEdge1.addReceive { input in
      latest1 = input
      callProcess()
    }
    upstreamEdge2.addReceive { input in
      latest2 = input
      callProcess()
    }

    return managedSelf
  }
}


// MARK: - Upstream Edges: Three

extension Node {
  @discardableResult
  func callAsFunction<In1, In2, In3, E1: Edgy, E2: Edgy, E3: Edgy>(
    _ upstreamEdge1: E1,
    _ upstreamEdge2: E2,
    _ upstreamEdge3: E3,
    setUpDownstreamNodes: (Edge<Out>) -> Void = { _ in }
  ) -> ManagedNode<Self> where In == (In1, In2, In3), E1.Out == In1, E2.Out == In2, E3.Out == In3 {
    setUp(upstreamEdge1, upstreamEdge2, upstreamEdge3, setUpDownstreamNodes: setUpDownstreamNodes)
  }

  @discardableResult
  func setUp<In1, In2, In3, E1: Edgy, E2: Edgy, E3: Edgy>(
    _ upstreamEdge1: E1,
    _ upstreamEdge2: E2,
    _ upstreamEdge3: E3,
    setUpDownstreamNodes: (Edge<Out>) -> Void
  ) -> ManagedNode<Self> where In == (In1, In2, In3), E1.Out == In1, E2.Out == In2, E3.Out == In3 {
    let managedSelf = setUp(setUpDownstreamNodes: setUpDownstreamNodes)

    var latest1: In1?
    var latest2: In2?
    var latest3: In3?
    let callProcess = {
      guard let latest1, let latest2, let latest3 else { return }
      process(input: (latest1, latest2, latest3))
    }

    upstreamEdge1.addReceive { input in
      latest1 = input
      callProcess()
    }
    upstreamEdge2.addReceive { input in
      latest2 = input
      callProcess()
    }
    upstreamEdge3.addReceive { input in
      latest3 = input
      callProcess()
    }

    return managedSelf
  }
}


// MARK: - Upstream Edges: Four

extension Node {
  @discardableResult
  func callAsFunction<In1, In2, In3, In4, E1: Edgy, E2: Edgy, E3: Edgy, E4: Edgy>(
    _ upstreamEdge1: E1,
    _ upstreamEdge2: E2,
    _ upstreamEdge3: E3,
    _ upstreamEdge4: E4,
    setUpDownstreamNodes: (Edge<Out>) -> Void = { _ in }
  ) -> ManagedNode<Self> where In == (In1, In2, In3, In4), E1.Out == In1, E2.Out == In2, E3.Out == In3, E4.Out == In4 {
    setUp(upstreamEdge1, upstreamEdge2, upstreamEdge3, upstreamEdge4, setUpDownstreamNodes: setUpDownstreamNodes)
  }

  @discardableResult
  func setUp<In1, In2, In3, In4, E1: Edgy, E2: Edgy, E3: Edgy, E4: Edgy>(
    _ upstreamEdge1: E1,
    _ upstreamEdge2: E2,
    _ upstreamEdge3: E3,
    _ upstreamEdge4: E4,
    setUpDownstreamNodes: (Edge<Out>) -> Void
  ) -> ManagedNode<Self> where In == (In1, In2, In3, In4), E1.Out == In1, E2.Out == In2, E3.Out == In3, E4.Out == In4 {
    let managedSelf = setUp(setUpDownstreamNodes: setUpDownstreamNodes)

    var latest1: In1?
    var latest2: In2?
    var latest3: In3?
    var latest4: In4?
    let callProcess = {
      guard let latest1, let latest2, let latest3, let latest4 else { return }
      process(input: (latest1, latest2, latest3, latest4))
    }

    upstreamEdge1.addReceive { input in
      latest1 = input
      callProcess()
    }
    upstreamEdge2.addReceive { input in
      latest2 = input
      callProcess()
    }
    upstreamEdge3.addReceive { input in
      latest3 = input
      callProcess()
    }
    upstreamEdge4.addReceive { input in
      latest4 = input
      callProcess()
    }

    return managedSelf
  }
}
