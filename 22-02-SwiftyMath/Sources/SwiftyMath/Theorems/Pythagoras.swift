import Foundation


public struct Pythagoras {
  public let a: CGFloat
  public let b: CGFloat
  public let c: CGFloat

  @inlinable
  public init(a: CGFloat, b: CGFloat) {
    self.a = a
    self.b = b
    self.c = sqrt(pow(a, 2) + pow(b, 2))
  }

  @inlinable
  public init(a: CGFloat, c: CGFloat) {
    self.a = a
    self.b = sqrt(pow(c, 2) - pow(a, 2))
    self.c = c
  }

  @inlinable
  public init(b: CGFloat, c: CGFloat) {
    self.a = sqrt(pow(c, 2) - pow(b, 2))
    self.b = b
    self.c = c
  }
}
