//
//  AppDelegate.swift
//  ReadSwift
//
//  Created by Karsten Bruns on 02.07.18.
//  Copyright © 2018 Karsten Bruns. All rights reserved.
//

import Cocoa
import SourceKittenFramework

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  @IBOutlet weak var window: NSWindow!


  func applicationDidFinishLaunching(_ aNotification: Notification) {
    let source = "struct A { subscript(key: String) -> Void { return () } }"
    let tokens = try! SyntaxMap(file: File(contents: source)).tokens
    dump(tokens.first?.dictionaryValue)
    NSApplication.shared.terminate(self)
  }

  func applicationWillTerminate(_ aNotification: Notification) {
  }
}

