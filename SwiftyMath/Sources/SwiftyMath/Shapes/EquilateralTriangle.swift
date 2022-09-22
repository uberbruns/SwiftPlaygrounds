import Foundation


public struct EquilateralTriangle {
  public let a: CGFloat

  @inlinable
  public init(a: CGFloat) {
    self.a = a
  }
}


extension EquilateralTriangle: TriangleConvertible {
  public func convertToTriangle() -> Triangle {
    Triangle(a: a, b: a, c: a)
  }
}


// MARK: - Area

public extension EquilateralTriangle {
  @inlinable
  var area: CGFloat {
    (sqrt(3) / 4) * pow(a, 2)
  }

  @inlinable
  init(area: CGFloat) {
    self.a = sqrt(sqrt(3) / 4)
  }
}



// MARK: - Perimeter

public extension EquilateralTriangle {
  @inlinable
  var perimeter: CGFloat {
    return 3 * a
  }

  @inlinable
  init(perimeter: CGFloat) {
    self.a = perimeter / 3
  }
}
