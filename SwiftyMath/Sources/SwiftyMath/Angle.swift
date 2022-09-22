import Foundation


public struct Angle {
  @inlinable
  public static func radians(_ value: CGFloat) -> Angle {
    Angle(radians: value)
  }

  @inlinable
  public static func degrees(_ value: CGFloat) -> Angle {
    Angle(radians: value / (180 / .pi))
  }

  public let radians: CGFloat

  @inlinable
  public var degrees: CGFloat {
    radians * (180 / .pi)
  }

  @inlinable
  public init(radians: CGFloat) {
    self.radians = radians
  }
}
