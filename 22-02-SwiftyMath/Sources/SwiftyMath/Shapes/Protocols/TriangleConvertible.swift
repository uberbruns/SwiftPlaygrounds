import Foundation


public protocol TriangleConvertible {
  @inlinable
  func convertToTriangle() -> Triangle

  var alpha: Angle { get }
  var beta: Angle { get }
  var gamma: Angle { get }

  var area: CGFloat { get }
  var perimeter: CGFloat { get }
  var semiperimeter: CGFloat { get }

  var altitudeToA: CGFloat { get }
  var altitudeToB: CGFloat { get }
  var altitudeToC: CGFloat { get }

  var incircleRadius: CGFloat { get }
  var circumcircleRadius: CGFloat { get }
}


// MARK: - Angle

public extension TriangleConvertible {
  @inlinable
  var alpha: Angle {
    let triangle = convertToTriangle()
    let a = triangle.a
    let b = triangle.b
    let c = triangle.c

    return .radians(
      acos((pow(b, 2) + pow(c, 2) - pow(a, 2)) / (2 * b * c))
    )
  }

  @inlinable
  var beta: Angle {
    let triangle = convertToTriangle()
    let a = triangle.a
    let b = triangle.b
    let c = triangle.c

    return .radians(
      acos((pow(a, 2) + pow(c, 2) - pow(b, 2)) / (2 * a * c))
    )
  }

  @inlinable
  var gamma: Angle {
    let triangle = convertToTriangle()
    let a = triangle.a
    let b = triangle.b
    let c = triangle.c

    return .radians(
      acos((pow(a, 2) + pow(b, 2) - pow(c, 2)) / (2 * a * b))
    )
  }
}


// MARK: - Area

public extension TriangleConvertible {
  @inlinable
  var area: CGFloat {
    let triangle = convertToTriangle()
    let a = triangle.a
    return (a * altitudeToA) / 2
  }
}


// MARK: - Perimeter

public extension TriangleConvertible {
  @inlinable
  var perimeter: CGFloat {
    let triangle = convertToTriangle()
    let a = triangle.a
    let b = triangle.b
    let c = triangle.c
    return a + b + c
  }

  @inlinable
  var semiperimeter: CGFloat {
    perimeter / 2
  }
}


// MARK: - Altitudes

public extension TriangleConvertible {
  @inlinable
  var altitudeToA: CGFloat {
    let triangle = convertToTriangle()
    let a = triangle.a
    let b = triangle.b
    let c = triangle.c
    let s = semiperimeter
    return (2 / a) * sqrt(s * (s - a) * (s - b) * (s - c))
  }

  @inlinable
  var altitudeToB: CGFloat {
    let triangle = convertToTriangle()
    let a = triangle.a
    let b = triangle.b
    let c = triangle.c
    let s = semiperimeter
    return (2 / b) * sqrt(s * (s - a) * (s - b) * (s - c))
  }

  @inlinable
  var altitudeToC: CGFloat {
    let triangle = convertToTriangle()
    let a = triangle.a
    let b = triangle.b
    let c = triangle.c
    let s = semiperimeter
    return (2 / c) * sqrt(s * (s - a) * (s - b) * (s - c))
  }
}


// MARK: - Incircle Radius

public extension TriangleConvertible {
  @inlinable
  var incircleRadius: CGFloat {
    (2 * area) / perimeter
  }

  @inlinable
  var circumcircleRadius: CGFloat {
    let triangle = convertToTriangle()
    let a = triangle.a
    let b = triangle.b
    let c = triangle.c
    return (a * b * c) / (4 * area)
  }
}
