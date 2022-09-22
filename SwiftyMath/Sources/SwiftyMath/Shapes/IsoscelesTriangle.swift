import Foundation


public struct IsoscelesTriangle {
  public let a: CGFloat
  public let c: CGFloat

  @inlinable
  public init(a: CGFloat, c: CGFloat) {
    self.a = a
    self.c = c
  }
}


extension IsoscelesTriangle: TriangleConvertible {
  @inlinable
  public func convertToTriangle() -> Triangle {
    Triangle(a: a, b: a, c: c)
  }
}


public extension IsoscelesTriangle {
  @inlinable
  var height: CGFloat {
    Pythagoras(a: a / 2, c: c).b
  }
}


public extension IsoscelesTriangle {
  @inlinable
  var altitudeToC: CGFloat {
    height
  }
}
