//
//  AtomicProtocols.swift
//  AtomicArchitecture
//
//  Created by Karsten Bruns on 30.06.18.
//  Copyright © 2018 Karsten Bruns. All rights reserved.
//


import UIKit


func with<T: AnyObject>(_ target: T, _ handler: @escaping (T) -> ()) -> () -> () {
  return { [weak target] in
    guard let target = target else { return }
    handler(target)
  }
}



protocol AnySystem: AnyObject {
  func rendererDidChangeState(to state: RendererState, oldState: RendererState)
}


protocol System: AnySystem {
  associatedtype RendererType: Renderer
  func updateRenderer()
  var renderer: RendererType { get }
}


protocol Differentiatable {
  var identity: AnyHashable { get }
  var hashValue: Int { get }
}


protocol Element: Differentiatable { }


protocol Group: Differentiatable { }


protocol Renderer: AnyObject {
  var system: AnySystem? { get set }
  func render()
}


protocol RenderTarget: Renderer { }


enum RendererState {
  case initialized
  case didLoad
  case willAppear
  case didAppear
  case willDisappear
  case didDisappear
}


///////////////////////////////////////


class Service {
  func doSomething(x: Int) { }
}


class MessageListSystem<R>: System where R: ContentRenderTarget, R: HeaderRenderTarget {

  typealias RendererType = R

  var renderer: R
  var service = Service()

  init(renderer: R) {
    self.renderer = renderer
  }

  func updateRenderer() {
    let actions = ContentGroup(identity: "actions", elements: { () -> [ContentElement] in
      var done = ActionElement(identity: "newMessage", title: "New Message")
      done.actionHandler = with(service) { $0.doSomething(x: 23) }
      return [done]
    }())

    renderer.contentGroups = [actions]
    renderer.render()
  }

  func rendererDidChangeState(to state: RendererState, oldState: RendererState) {
    if state == .didLoad {
      updateRenderer()
    }
  }

  private func test() -> Int {
    return 42
  }


  private func handleDoneElementAction() {

  }
}


///////////////////////////////////////


protocol ContentRenderTarget: RenderTarget {
  var contentGroups: [ContentGroup] { get set }
}


struct ContentGroup: Group, Hashable {

  let identity: AnyHashable
  var elements: [ContentElement]

  static func == (lhs: ContentGroup, rhs: ContentGroup) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(identity)
    elements.forEach { hasher.combine($0.hashValue) }
  }
}


protocol ContentElement: Element {
  var type: String { get }
}


////


protocol HeaderRenderTarget: RenderTarget {
  var headerGroups: [HeaderGroup] { get set }
}


struct HeaderGroup: Group, Hashable {
  let identity: AnyHashable
  var elements: [HeaderElement]

  static func ==(lhs: HeaderGroup, rhs: HeaderGroup) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(identity)
    elements.forEach { hasher.combine($0.hashValue) }
  }
}


protocol HeaderElement: Element {
}


////


protocol ToolbarElement: Element {
}


////////////


struct ActionElement: ContentElement, HeaderElement, ToolbarElement, Hashable {

  let identity: AnyHashable
  let type = "action"
  var title: String

  typealias ActionHandler = () -> ()
  var actionHandler: ActionHandler?

  init(identity: AnyHashable, title: String) {
    self.identity = identity
    self.title = title
  }

  static func ==(lhs: ActionElement, rhs: ActionElement) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(identity)
    hasher.combine(title)
  }
}


////////////


class StandardRendererViewController: UIViewController, ContentRenderTarget, HeaderRenderTarget {

  weak var system: AnySystem?

  var contentGroups = [ContentGroup]()
  var headerGroups = [HeaderGroup]()

  var state = RendererState.initialized {
    didSet {
      system?.rendererDidChangeState(to: state, oldState: oldValue)
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    state = .didLoad
  }

  func render() { }
}
