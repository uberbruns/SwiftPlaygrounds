import Foundation


public struct Triangle: TriangleConvertible {
  public let a: CGFloat
  public let b: CGFloat
  public let c: CGFloat

  public init(a: CGFloat, b: CGFloat, c: CGFloat) {
    self.a = a
    self.b = b
    self.c = c
  }

  public func convertToTriangle() -> Triangle {
    self
  }
}
