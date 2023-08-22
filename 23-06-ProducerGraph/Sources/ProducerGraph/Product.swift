import Foundation
import AsyncAlgorithms


@propertyWrapper
final class ProductOutlet<Value> {

  private let channel = AsyncChannel<Value>()

  var wrappedValue: Value

  var projectedValue: ProductOutlet<Value> {
    self
  }

  var values: some AsyncSequence {
    combineLatest(
      [wrappedValue].async,
      channel
    )
  }

  func publish() async {
    await channel.send(wrappedValue)
  }

  init(wrappedValue: Value) {
    self.wrappedValue = wrappedValue
  }
}
