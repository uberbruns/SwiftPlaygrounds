import Foundation


// MARK: - Core Protocols

protocol FlagValue<Value> {
  associatedtype Body
  associatedtype Value

  var body: Body { get }

  var isMutable: Bool { get }

  func get() -> Value

  @discardableResult
  func set(value: Value) -> Bool

  func reset()
}


extension FlagValue where Body: FlagValue<Value>{

  var isMutable: Bool {
    return body.isMutable
  }

  func get() -> Body.Value {
    return body.get()
  }

  @discardableResult
  func set(value: Value) -> Bool {
    self.body.set(value: value)
  }

  func reset() {
    self.body.reset()
  }
}


extension FlagValue where Body == Never {
  var body: Body {
    fatalError()
  }
}


// MARK: - Implementations

struct DefaultFlagValue<Constant>: FlagValue {
  typealias Body = Never

  let value: Constant

  let isMutable = false

  init(_ value: Constant) {
    self.value = value
  }

  func get() -> Constant {
    return value
  }

  func set(value: Constant) -> Bool {
    return false
  }

  func reset() { }
}


var mutableFlagValue = [String: Any]()

struct MutableFlagValue<Variable>: FlagValue {

  typealias Body = Never

  let isMutable = true

  var key: String

  func get() -> Variable? {
    return mutableFlagValue[key] as? Variable
  }

  func set(value: Variable?) -> Bool {
    mutableFlagValue[key] = value
    return true
  }

  func reset() {
    mutableFlagValue.removeValue(forKey: key)
  }
}

extension FlagValue {
  func userDefaults<V>(key: String, ignoreOnProduction: Bool) -> some FlagValue<V> where V == Value {
    self.override(with: MutableFlagValue<V>(key: key))
  }

  func remoteValue<V>(key: String) -> some FlagValue<V> where V == Value {
    self.override(with: MutableFlagValue<V>(key: key))
  }
}




struct OverrideFlagValue<Overridden: FlagValue, Overriding: FlagValue>: FlagValue where Overriding.Value == Optional<Overridden.Value>  {
  typealias Body = Never

  let overridden: Overridden
  let overriding: Overriding

  var isMutable: Bool {
    if overriding.isMutable {
      return true
    } else {
      return overridden.isMutable
    }
  }

  func get() -> Overridden.Value {
    overriding.get() ?? overridden.get()
  }

  func set(value: Overridden.Value) -> Bool {
    if overriding.set(value: value) {
      return true
    } else {
      return overridden.set(value: value)
    }
  }

  func reset() {
    overriding.reset()
    overridden.reset()
  }
}


extension FlagValue {
  func `override`<Overriding: FlagValue>(with overridingFlagValue: Overriding) -> some FlagValue<Value> where Overriding.Value == Optional<Value> {
    OverrideFlagValue(overridden: self, overriding: overridingFlagValue)
  }
}


// MARK: - Usage

struct MyFlagValue: FlagValue {
  var body: some FlagValue<Int> {
    DefaultFlagValue(1)
      .remoteValue(key: "my_flag")
      .userDefaults(key: "myFlag", ignoreOnProduction: true)
  }
}


let flag = MyFlagValue()
flag.set(value: 3)
print(flag.get(), flag.isMutable)
