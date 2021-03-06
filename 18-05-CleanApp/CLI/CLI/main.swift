#!/usr/bin/swift

//
//  main.swift
//  CLI
//
//  Created by Karsten Bruns on 21.05.18.
//  Copyright © 2018 Karsten Bruns. All rights reserved.
//

import Foundation

// ============================
// MARK: CLI Helper
// ============================

enum CLI {
  static let `init` = Mode(label: "init")
  static let update = Mode(label: "update")
  static let output = Parameter(shortLabel: "o", label: "output", default: ".")
  static let framework = Parameter(shortLabel: "f", label: "framework", default: "./CleanSwift/")
  static let group = Parameter<String?>(shortLabel: "g", label: "group", default: nil)
  static let name = Parameter<String?>(shortLabel: "n", label: "name", default: nil)

  struct Mode {
    let label: String
  }

  struct Parameter<T: StringInitializable> {
    let shortLabel: String
    let label: String
    let `default`: T
  }

  static func mode(is mode: CLI.Mode) -> Bool {
    let arguments = CommandLine.arguments
    if arguments.count >= 2 {
      return arguments[1] == mode.label
    }
    return false
  }

  static func value<T: StringInitializable>(for parameter: CLI.Parameter<T>) -> T {
    let arguments = CommandLine.arguments
    var valueIndex: Int?
    for (index, argument) in arguments.enumerated() where argument == "-" + parameter.shortLabel || argument == "--" + parameter.label {
      valueIndex = index + 1
      break
    }

    if let valueIndex = valueIndex, valueIndex < arguments.count {
      return T.init(arguments[valueIndex]) ?? parameter.default
    }

    return parameter.default
  }

  static func shell(launchPath: String, arguments: [String]) -> String {
    let task = Process()
    task.launchPath = launchPath
    task.arguments = arguments

    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: String.Encoding.utf8)!
    if output.count > 0 {
      //remove newline character.
      let lastIndex = output.index(before: output.endIndex)
      return String(output[output.startIndex ..< lastIndex])
    }
    return output
  }

  static func bash(_ command: String, arguments: [String]) -> String {
    let whichPathForCommand = shell(launchPath: "/bin/bash", arguments: [ "-l", "-c", "which \(command)" ])
    return shell(launchPath: whichPathForCommand, arguments: arguments)
  }
}

protocol StringInitializable {
  init?(_ value: String)
}

extension String: StringInitializable { }
extension Int: StringInitializable { }
extension Bool: StringInitializable { }
extension Optional: StringInitializable where Wrapped: StringInitializable {
  init?(_ value: String) {
    self = Wrapped.init(value)
  }
}


// ============================
// MARK: Templates
// ============================

struct Template {

  static let author = { return CLI.bash("id", arguments: ["-F"]) }()

  static let header = """
  //
  //  %FILENAME%
  //  Neptune
  //
  //  Created by %AUTHOR% on %DAY%.%MONTH%.%YEAR%.
  //  Copyright © %YEAR% MOIA GmbH. All rights reserved.
  //

  import UIKit
  import CleanSwift


  """

  static let scene = Template(appendix: "Scene", body: """
  class %%%Scene: SceneProtocol {

    private let userInterface = %%%ViewController()

    func build(_ startRouting: (%%%Router<%%%ViewController>) -> Void) {
      let router = %%%Router<%%%ViewController>(userInterface: userInterface)
      let presenter = %%%Presenter(userInterface: userInterface)
      let interactor = %%%Interactor(router: router, presenter: presenter)
      userInterface.interactor = interactor
      router.dataStore = interactor
      startRouting(router)
    }
  }
  """)

  static let router = Template(appendix: "Router", body: """
  protocol %%%RouterProtocol: RouterProtocol where UserInterfaceType: %%%UserInterfaceProtocol {
    var dataStore: %%%DataStoreProtocol? { get set }
    func routeTo%%%View()
  }

  class %%%Router<UI: %%%UserInterfaceProtocol & UIViewController>: %%%RouterProtocol {
    weak var dataStore: %%%DataStoreProtocol?
    private weak var userInterface: UI!

    required init(userInterface: UI) {
      self.userInterface = userInterface
    }

    func start(options: RoutingOptions) {
      switch options {
      case .embedInWindow(let window):
        let navigationController = UINavigationController(rootViewController: userInterface)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
      case .show(let currentViewController):
        currentViewController.navigationController?.pushViewController(userInterface, animated: true)
      default:
        break
      }
    }
  }
  """)

  static let useCase = Template(appendix: "UseCase", body: """
  enum %%%UseCase: UseCaseProtocol {
    enum ViewDidLoad {
      struct Request { }
      struct Response { }
      struct ViewModel { }
    }
  }
  """)

  static let interactor = Template(appendix: "Interactor", body: """
  class %%%Interactor<RO: %%%RouterProtocol, PR: %%%PresenterProtocol>: %%%InteractorProtocol {

    private let presenter: PR
    private let router: RO

    required init(router: RO, presenter: PR) {
      self.presenter = presenter
      self.router = router
    }
  }
  """)

  static let presenter = Template(appendix: "Presenter", body: """
  class %%%Presenter<UI: %%%UserInterfaceProtocol>: %%%PresenterProtocol {
    private weak var userInterface: UI!

    required init(userInterface: UI) {
      self.userInterface = userInterface
    }
  }
  """)

  static let viewController = Template(appendix: "ViewController", body: """
  class %%%ViewController: UIViewController, %%%UserInterfaceProtocol {
    var interactor: %%%BusinessLogicProtocol?

    override func viewDidLoad() {
      super.viewDidLoad()
      interactor?.doViewDidLoad(with: %%%UseCase.ViewDidLoad.Request())
    }
  }
  """)

  let appendix: String
  let body: String

  private func render(templateString: String, name: String, filename: String = "") -> String {
    let date = Calendar(identifier: .gregorian).dateComponents([.day, .month, .year], from: Date())
    return templateString.replacingOccurrences(of: "%%%", with: name)
      .replacingOccurrences(of: "%AUTHOR%", with: Template.author)
      .replacingOccurrences(of: "%FILENAME%", with: filename)
      .replacingOccurrences(of: "%DAY%", with: "\(date.day!)")
      .replacingOccurrences(of: "%MONTH%", with: "\(date.month!)")
      .replacingOccurrences(of: "%YEAR%", with: "\(date.year!)")
      .replacingOccurrences(of: "SceneScene", with: "Scene")
  }

  func write(name: String, directory: URL) throws {
    let filename = render(templateString: (name + appendix), name: name)
    let path = directory.appendingPathComponent("\(filename).swift", isDirectory: false)
    try render(templateString: (Template.header + body), name: name, filename: path.lastPathComponent).write(to: path, atomically: true, encoding: .utf8)
  }
}


// ============================
// MARK: Main
// ============================

do {
  let fileManager = FileManager.default
  let currentDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath)
  var outputDir = URL(fileURLWithPath: NSString(string: CLI.value(for: CLI.output)).expandingTildeInPath, relativeTo: currentDirectory)
  let frameworkDir = URL(fileURLWithPath: NSString(string: CLI.value(for: CLI.framework)).expandingTildeInPath, relativeTo: currentDirectory)

  let group: String
  let name: String

  if let parsedGroup = CLI.value(for: CLI.group), let parsedName = CLI.value(for: CLI.name) {
    outputDir.appendPathComponent(parsedName, isDirectory: true)
    outputDir.appendPathComponent(parsedGroup, isDirectory: true)
    name = parsedName
    group = parsedGroup
  } else {
    name = outputDir.lastPathComponent; outputDir.deleteLastPathComponent()
    group = outputDir.lastPathComponent; outputDir.deleteLastPathComponent()
  }
  
  let resolvedOutputDir = outputDir.appendingPathComponent(group, isDirectory: true).appendingPathComponent(name, isDirectory: true)
  let resolvedOutputPath = resolvedOutputDir.appendingPathComponent("\(group)\(name)Protocols.swift", isDirectory: false)

  func update() {
    let arguments = ["--sources", resolvedOutputDir.path, "--sources", frameworkDir.path, "--templates", frameworkDir.path, "--output", resolvedOutputPath.path]
    let result = CLI.bash("sourcery", arguments: arguments)
    print(result)
  }

  func initiate() throws {
    try fileManager.createDirectory(at: resolvedOutputDir, withIntermediateDirectories: true, attributes: nil)
    try Template.scene.write(name: group + name, directory: resolvedOutputDir)
    try Template.router.write(name: group + name, directory: resolvedOutputDir)
    try Template.useCase.write(name: group + name, directory: resolvedOutputDir)
    try Template.interactor.write(name: group + name, directory: resolvedOutputDir)
    try Template.presenter.write(name: group + name, directory: resolvedOutputDir)
    try Template.viewController.write(name: group + name, directory: resolvedOutputDir)
  }

  if CLI.mode(is: CLI.update) {
    update()
  } else if CLI.mode(is: CLI.init) {
    try initiate()
    update()
  }

} catch (let error) {
  print(error)
  exit(1)
}










