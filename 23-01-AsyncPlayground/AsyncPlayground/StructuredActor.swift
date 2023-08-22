import Foundation


private protocol ManagedTask {
  func cancel()
  var isCancelled: Bool { get }
}


extension Task: ManagedTask { }


class ActorContext {
  fileprivate typealias TaskID = UInt

  private var latestTaskID: TaskID = 0

  private var taskStore = TaskStore()

  fileprivate func add(id: TaskID, task: any ManagedTask) async {
    await taskStore.add(id: id, task: task)
  }

  fileprivate func remove(id: TaskID) async {
    await taskStore.remove(id: id)
  }

  fileprivate func newTaskID() -> TaskID {
    latestTaskID += 1
    return latestTaskID
  }

  fileprivate func increaseAttachedActorsCount() async {
    await taskStore.increaseAttachedActorsCount()
  }

  fileprivate func decreaseAttachedActorsCount() async {
    await taskStore.decreaseAttachedActorsCount()
  }
}


private extension ActorContext {
  actor TaskStore {
    var tasks = [TaskID: any ManagedTask]()

    var earlyCompletedTasks = Set<TaskID>()

    var attachedActorsCount = 0 {
      didSet {
        if attachedActorsCount == 0 {
          tasks.forEach { $0.value.cancel() }
          tasks.removeAll()
        }
      }
    }

    func add(id: TaskID, task: any ManagedTask) async {
      if earlyCompletedTasks.contains(id) {
        earlyCompletedTasks.remove(id)
        print("removed early completed task")
      } else {
        tasks[id] = task
      }
    }

    func remove(id: TaskID) async {
      if tasks[id] == nil {
        earlyCompletedTasks.insert(id)
      } else {
        tasks.removeValue(forKey: id)
      }
    }

    func increaseAttachedActorsCount() async {
      attachedActorsCount += 1
    }

    func decreaseAttachedActorsCount() async {
      attachedActorsCount -= 1
    }
  }
}


protocol StructuredActor: AnyActor {
  var context: ActorContext { get }
}


extension StructuredActor {
  @discardableResult
  func attachTask<Success>(@_inheritActorContext @_implicitSelfCapture operation: @escaping @Sendable () async -> Success) -> Task<Success, Never> {
    let newTaskID = context.newTaskID()
    let task = Task {
      let result = await operation()
      await context.remove(id: newTaskID)
      return result
    }
    Task {
      await context.add(id: newTaskID, task: task)
    }
    return task
  }
}


@propertyWrapper
class Attached<A: StructuredActor> {

  var wrappedValue: A

  init(wrappedValue: A) {
    self.wrappedValue = wrappedValue
    Task {
      await wrappedValue.context.increaseAttachedActorsCount()
    }
  }

  deinit {
    let wrappedValue = wrappedValue
    Task {
      await wrappedValue.context.decreaseAttachedActorsCount()
    }
  }
}
