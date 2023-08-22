//
//  AppDelegate.swift
//  Test
//
//  Created by Karsten Bruns on 14.04.23.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

  @IBOutlet var window: NSWindow!

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    let userDefaults = UserDefaults(suiteName: "test")!
    userDefaults.removePersistentDomain(forName: "test")
    let loop = Task { @MainActor in
      for await value in userDefaults.values(key: "foo", type: String.self) {
        print(value)
      }
      print("ended")
    }
    Task { @MainActor in
      try! await Task.sleep(for: .seconds(1))
      userDefaults.setValue("bar", forKey: "foo")
      print(userDefaults.value(forKey: "foo") as! String)
      try! await Task.sleep(for: .seconds(1))
      loop.cancel()
    }
  }


  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }

  func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }


}



final class UserDefaultsMonitor: NSObject {

  private let key: String

  private let userDefaults: UserDefaults

  private let valueHandler: (Any) -> Void

  private var retained: Any?

  init(key: String, userDefaults: UserDefaults, valueHandler: @escaping (Any) -> Void) {
    self.key = key
    self.userDefaults = userDefaults
    self.valueHandler = valueHandler
    super.init()
    userDefaults.addObserver(self, forKeyPath: key, options: [.new], context: nil)
  }

  deinit {
    userDefaults.removeObserver(self, forKeyPath: key)
  }

  func retain() {
    retained = self
  }

  func release() {
    retained = nil
  }

  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
    if let value = change?[NSKeyValueChangeKey.newKey] {
      valueHandler(value)
    }
  }
}


extension UserDefaults {
  func values<T>(key: String, type: T.Type) -> AsyncStream<T> {
    return AsyncStream(T.self) { continuation in
      let monitor = UserDefaultsMonitor(key: key, userDefaults: self) { value in
        continuation.yield(value as! T)
      }
      monitor.retain()
      continuation.onTermination = { termination in
        monitor.release()
      }
    }
  }
}

