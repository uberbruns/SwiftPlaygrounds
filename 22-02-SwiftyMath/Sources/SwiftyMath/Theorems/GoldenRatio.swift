import Foundation


public struct GoldenRatio {
  public static let value = (1 + sqrt(5)) / 2

  public let a: CGFloat
  public let b: CGFloat

  @inlinable
  public var sum: CGFloat {
    a + b
  }

  @inlinable
  public init(a: CGFloat) {
    self.a = a
    self.b = a / Self.value
  }

  @inlinable
  public init(b: CGFloat) {
    self.a = b * Self.value
    self.b = b
  }

  @inlinable
  public init(sum: CGFloat) {
    let a = (1 / Self.value) * sum
    self.a = a
    self.b = a / Self.value
  }
}
