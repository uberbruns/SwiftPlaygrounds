import Foundation


actor TestActor: StructuredActor {

  let context = ActorContext()

  init() {
    print("Init")
    Task {
      await start()
    }
  }

  deinit {
    print("Deinit")
  }

  func start() async {
    attachTask {
      print("Task Begins")
      for await _ in AsyncStream.t1000 { }
      print("Task Ended")
      if !Task.isCancelled {
        act()
      }
    }
  }

  func act() {
    print("Act called")
  }
}


extension AsyncStream where Element == Bool {
  static var t1000: AsyncStream<Bool> {
    return AsyncStream<Bool> { continuation in
      continuation.onTermination = { _ in
        print("👍")
      }
      return
    }
  }
}
