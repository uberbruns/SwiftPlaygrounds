public struct FibonacciNumbers {
  public let sequence: [Int]

  @inlinable
  public init(count: Int) {
    if count >= 2 {
      sequence = Array(unsafeUninitializedCapacity: count) { buffer, initializedCount in
        initializedCount = count
        buffer[0] = 0
        buffer[1] = 1
        for i in 2..<count {
          buffer[i] = buffer[i - 2] + buffer[i - 1]
        }
      }
    } else if count == 1 {
      sequence = [0]
    } else {
      sequence = []
    }
  }
}
