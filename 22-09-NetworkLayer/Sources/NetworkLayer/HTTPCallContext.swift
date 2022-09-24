import Foundation


final actor HTTPCallContext {

  typealias TaskHandler = (URLSessionTask) -> Void

  let urlSession: URLSession

  private var taskHandlers = [(URLSessionTask) -> Void]()

  init(urlSession: URLSession) {
    self.urlSession = urlSession
  }

  func add(taskHandler: @escaping TaskHandler) {
    taskHandlers.append(taskHandler)
  }

  func invokeTaskHandlers(with task: URLSessionTask) {
    for taskHandler in taskHandlers {
      taskHandler(task)
    }
  }
}
