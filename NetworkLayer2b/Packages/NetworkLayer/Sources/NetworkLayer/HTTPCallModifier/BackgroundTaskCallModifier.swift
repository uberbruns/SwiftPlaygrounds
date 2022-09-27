#if canImport(UIKit)
import Foundation
import UIKit


@available(iOS 13.0, *)
public struct BackgroundTaskCallModifier<ResponseBody>: HTTPCallModifier  {
  public func call(configuration: HTTPCallConfiguration, execute: (HTTPCallConfiguration) async throws -> (ResponseBody, HTTPURLResponse)) async throws -> (ResponseBody, HTTPURLResponse) {
    let taskIdentifier = await UIApplication.shared.beginBackgroundTask()
    let (responseBody, response) = try await withTaskCancellationHandler {
      Task.detached {
        await UIApplication.shared.endBackgroundTask(taskIdentifier)
      }
    } operation: {
      try await execute(configuration)
    }
    await UIApplication.shared.endBackgroundTask(taskIdentifier)
    return (responseBody, response)
  }
}


@available(iOS 13.0, *)
public extension HTTPCall {
  var backgroundTask: some HTTPCall<ResponseBody> {
    modifier(BackgroundTaskCallModifier())
  }
}
#endif
