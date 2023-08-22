import Foundation


final class ProducerA: Node {
  let connection = Connection<Int>()
  func receive(_ incoming: Void) {
    print(self, incoming)
    send(1)
  }
}


final class ProducerB: Node {
  let connection = Connection<String>()
  func receive(_ incoming: Int) {
    print(self, incoming)
    send("\(incoming)")
  }
}


final class ProducerC: Node {
  let connection = Connection<String>()
  func receive(_ incoming: Int) {
    print(self, incoming)
  }
}


final class ProducerD: Node {
  let connection = Connection<String>()
  func receive(_ incoming: (Int, String)) {
    print(self, incoming)
  }
}



class ComplexSubsystem {

  let producerA = ProducerA()
  let producerB = ProducerB()
  let producerC = ProducerC()
  let producerD = ProducerD()

  var graph: Graph?

  init() {
    graph = Graph {
      producerA { a in
        producerB(a) { b in
          producerD(a, b)
        }
        producerC(a)
      }
    }
  }
}


let complexSubsysten = ComplexSubsystem()

