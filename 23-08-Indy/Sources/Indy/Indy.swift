// The Swift Programming Language
// https://docs.swift.org/swift-book


@attached(peer, names: suffixed(Dependencies))
@attached(member, names: arbitrary)
public macro Dependent() = #externalMacro(module: "IndyMacros", type: "DependentMacro")

@attached(peer)
public macro Dependency() = #externalMacro(module: "IndyMacros", type: "DependencyMacro")


public protocol Dependencies { }


@propertyWrapper
public struct Parameter<T> {
  public var wrappedValue: T

  public init(wrappedValue: T) {
    self.wrappedValue = wrappedValue
  }
}
