import Foundation


/// A convex quadrilateral where all interior angles are less than 180°,
/// and the two diagonals both lie inside the quadrilateral.
public protocol QuadrilateralConvertible {
  @inlinable
  func convertToQuadrilateral() -> Quadrilateral

  var a: CGFloat { get }
  var b: CGFloat { get }
  var c: CGFloat { get }
  var d: CGFloat { get }
  var e: CGFloat { get }
  var f: CGFloat { get }

  var alpha: Angle { get }
  var beta: Angle { get }
  var gamma: Angle { get }
  var delta: Angle { get }

  var area: CGFloat { get }
  var perimeter: CGFloat { get }
}


// MARK: - Angles

public extension QuadrilateralConvertible {
  @inlinable
  var alpha: Angle {
    .radians(
      acos(
        (pow(a, 2) + pow(d, 2) - pow(f, 2)) /
        (2 * a * d)
      )
    )
  }

  @inlinable
  var beta: Angle {
    .radians(
      acos(
        (pow(a, 2) + pow(b, 2) - pow(e, 2)) /
        (2 * a * d)
      )
    )
  }

  @inlinable
  var gamma: Angle {
    .radians(
      acos(
        (pow(b, 2) + pow(c, 2) - pow(f, 2)) /
        (2 * b * c)
      )
    )
  }

  @inlinable
  var delta: Angle {
    .radians(
      acos(
        (pow(c, 2) + pow(d, 2) - pow(e, 2)) /
        (2 * c * d)
      )
    )
  }
}


// MARK: - Area

public extension QuadrilateralConvertible {
  @inlinable
  var area: CGFloat {
    (1 / 4) * sqrt(
      4 * pow(e, 2) * pow(f, 2) -
      pow(pow(b, 2) + pow(d, 2) - pow(a, 2) - pow(c, 2), 2)
    )
  }
}


// MARK: - Perimeter

public extension QuadrilateralConvertible {
  @inlinable
  var perimeter: CGFloat {
    a + b + c + d
  }
}
