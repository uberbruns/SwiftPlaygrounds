// MARK: - Protocol: Edgy

@dynamicMemberLookup
protocol Edgy {
  associatedtype Out
  var addReceive: (@escaping (Out) -> Void) -> Void { get }
}


// MARK: - Implementation: Edge

struct Edge<Out>: Edgy {
  static var null: Edge<Out> { Edge<Out>(addReceive: { _ in  }) }
  var addReceive: (@escaping (Out) -> Void) -> Void
}


// MARK: - Implementation: MappedEdge

struct MappedEdge<TransformedOut, OriginalEdge: Edgy>: Edgy {
  let originalEdge: OriginalEdge
  let transform: (OriginalEdge.Out) -> TransformedOut
  let addReceive: (@escaping (TransformedOut) -> Void) -> Void

  init(originalEdge: OriginalEdge, transform: @escaping (OriginalEdge.Out) -> TransformedOut) {
    self.originalEdge = originalEdge
    self.transform = transform
    self.addReceive = { receiver in
      originalEdge.addReceive({ originalOut -> Void in
        let transformedOut = transform(originalOut)
        receiver(transformedOut)
      })
    }
  }
}

extension Edgy {
  subscript<TransformedOut>(dynamicMember keyPath: KeyPath<Out, TransformedOut>) -> MappedEdge<TransformedOut, Self> {
    MappedEdge(originalEdge: self) { originalOut in
      originalOut[keyPath: keyPath]
    }
  }

  func map<TransformedOut>(transform: @escaping (Out) -> TransformedOut) -> MappedEdge<TransformedOut, Self> {
    MappedEdge(originalEdge: self, transform: transform)
  }
}
