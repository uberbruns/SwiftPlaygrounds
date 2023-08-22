import Foundation


struct ProductA { }

struct ProducerA: Node {
  let output = Output(ProductA.self)
  func process(input: Void) {
    send(ProductA())
  }
}


struct ProductB { }

struct ProducerB: Node {
  let output = Output(ProductB.self)
  func process(input: ProductA) {
    send(ProductB())
  }
}

struct ProductC { }

struct ProducerC: Node {
  let output = Output(ProductC.self)
  func process(input: (ProductA, ProductB)) {
    dump(input)
  }
}


@main
public struct ProducerGraph2 {
  public static func main() {
    let producerA = ProducerA()
    let producerB = ProducerB()
    let producerC = ProducerC()

    producerA { a in
      producerB(a) { b in
        producerC(a, b)
      }
    }

    print("Run 1")
    producerA.process(input: ())
    print("Run 2")
    producerA.process(input: ())

    /*
     let a = producerA.node
     let b = producerB.node(a)
     let c = producerA.node(b)
     let d = producerD.node(b, d)
     */
  }
}
