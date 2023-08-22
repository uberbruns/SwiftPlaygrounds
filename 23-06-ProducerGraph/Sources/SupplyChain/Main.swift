import AsyncAlgorithms
import Foundation


typealias Container = Dictionary<ObjectIdentifier, Any>


protocol Producer {
  associatedtype Input
  associatedtype Output

  func handle<S: AsyncSequence>(jobs: S) async where S.Element == Job<Input, Output>
}


protocol Destination {
  associatedtype Value
  func receive(value: Value)
}


final class Job<Input, Output> {

  let input: Input

  init(input: Input) {
    self.input = input
  }

  deinit {

  }

  func serialFinish(with output: Output) {

  }
  
  func concurrentFinish(with output: Output) {

  }
}


final class ManagedProducer {
  enum State {
    case upToDate
    case updating
    case outdated
  }

  let inputs: [ObjectIdentifier]
  let output: ObjectIdentifier
  let process: (SupplyChain) async -> Void
  var state = State.outdated

  init(inputs: [ObjectIdentifier], output: ObjectIdentifier, process: @escaping (SupplyChain) async -> Void) {
    self.inputs = inputs
    self.output = output
    self.process = process
  }
}




actor SupplyChain {

  var container = Container()

  var producers = [ManagedProducer]()

  func incorporate<O>(output: O) async {
    let objectID = ObjectIdentifier(O.self)
    container[O.self] = output
    for producer in producers where producer.inputs.contains(objectID) {
      producer.state = .outdated
    }
    await update()
  }

  func update() async {
    guard let outdatedProducer = producers.first(where: { $0.state == .outdated }) else {
      return
    }
    outdatedProducer.state = .updating
    await outdatedProducer.process(self)
    if outdatedProducer.state == .updating {
      outdatedProducer.state = .upToDate
    }
    await update()
  }

  func add(managedProducer: ManagedProducer) {
    var producers = self.producers
    producers.append(managedProducer)

    // Run Topological Sorting
    let map = producers.enumerated().reduce(into: [:], { $0[$1.element.output] = $1.offset })
    let algo = GraphAlgorithm(
      edges: producers.flatMap { producer in
        let producerID = producer.output
        return producer.inputs.map { inputID in
          GraphAlgorithm.Edge(
            source: map[inputID]!,
            destination: map[producerID]!
          )
        }
      },
      nodeCount: producers.count
    )
    let sortedProducers = algo.topologicalSorting().map { producers[$0] }

    // Apply Sorted Producers
    self.producers = sortedProducers
  }

  func add<P: Producer, D: Destination>(producer: P, deliverTo destination: D) async where P.Output == D.Value {
    let inputID = ObjectIdentifier(P.Input.self)
    let outputID = ObjectIdentifier(P.Output.self)
    let channel = AsyncChannel<Job<P.Input, P.Output>>()
    let managedProducer = ManagedProducer(
      inputs: [inputID],
      output: outputID,
      process: { supplyChain in
        let input = await supplyChain.container[P.Input.self]!
        let job = Job<P.Input, P.Output>(input: input)
        await channel.send(job)
      }
    )
    await producer.handle(jobs: channel)
    add(managedProducer: managedProducer)
    await managedProducer.process(self)
  }

//  func add<P: Producer, I1, I2>(producer: P, deliverTo destination: some Destination) where P.Input == (I1, I2) {
//    
//  }
//  
//  func add<P: Producer, I1, I2, I3>(producer: P, deliverTo destination: some Destination) where P.Input == (I1, I2, I3) {
//    
//  }
//  
//  func add<P: Producer, I1, I2, I3, I4>(producer: P, deliverTo destination: some Destination) where P.Input == (I1, I2, I3, I4) {
//    
//  }
//  
//  func add<P: Producer, I1, I2, I3, I4, I5>(producer: P, deliverTo destination: some Destination) where P.Input == (I1, I2, I3, I4, I5) {
//    
//  }
//  
//  func add<P: Producer, I1, I2, I3, I4, I5, I6>(producer: P, deliverTo destination: some Destination) where P.Input == (I1, I2, I3, I4, I5, I6) {
//
//  }
}




extension Container {
  subscript<V>(type: V.Type) -> V? {
    get {
      self[ObjectIdentifier(V.self)] as? V
    }
    set {
      self[ObjectIdentifier(V.self)] = newValue
    }
  }
}


struct Ship {
  let name: String
}



@main
public struct CLI {
  public static func main() {
    var container = Container()
    container[Ship.self] = Ship(name: "Enterprise")
    dump(container[Ship.self])
  }
}
