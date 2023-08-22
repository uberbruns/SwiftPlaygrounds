import Foundation


@main
public struct ProducerGraph {
  public static func main() {
    _ = ComplexSubsystem()
  }
}



class ComplexSubsystem {

  @Published var valueA = ""

  let authenticationProvider = ProducerA()
  let webSocketConnection = ProducerB()
  let profileRepository = ProducerC()
  let chatServer = ProducerD()

  var graph: Graph?

  init() {
    graph = Graph {
      authenticationProvider { authentication in
        webSocketConnection(authentication) { openConnection in
          chatServer(authentication, openConnection)
        }
        profileRepository(authentication)
      }
    }
  }
}



actor ProducerA: Node {
  let connection = Connection<Int>()
  nonisolated func receive(_ input: Void) {
    print(self, input)
    Task {
      await doSomething()
    }
  }

  func doSomething() {
    send(1)
  }
}


final class ProducerB: Node {
  let connection = Connection<String>()
  func receive(_ input: Int) {
    print(self, input)
    send("\(input)")
  }
}


final class ProducerC: Node {
  let connection = Connection<String>()
  func receive(_ input: Int) {
    print(self, input)
  }
}


final class ProducerD: Node {
  let connection = Connection<String>()
  func receive(_ input: (Int, String)) {
    print(self, input)
  }
}
