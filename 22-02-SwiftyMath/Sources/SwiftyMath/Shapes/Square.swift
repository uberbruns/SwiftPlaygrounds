import Foundation


public struct Square {
  public let a: CGFloat

  @inlinable
  public init(a: CGFloat) {
    self.a = a
  }
}


// MARK: - `QuadrilateralConvertible` Conformance

extension Square: QuadrilateralConvertible {
  @inlinable
  public var b: CGFloat { a }

  @inlinable
  public var c: CGFloat { a }

  @inlinable
  public var d: CGFloat { a }

  @inlinable
  public var e: CGFloat { diagonal }

  @inlinable
  public var f: CGFloat { diagonal }

  public func convertToQuadrilateral() -> Quadrilateral {
    Quadrilateral(a: a, b: b, c: c, d: d, e: e, f: f)
  }
}


// MARK: - Diagonal

public extension Square {
  @inlinable
  var diagonal: CGFloat {
    Pythagoras(a: a, b: a).c
  }

  @inlinable
  init(diagonal: CGFloat) {
    self.a = sqrt(diagonal / 2)
  }
}


// MARK: - Area

public extension Square {
  @inlinable
  var area: CGFloat {
    pow(a, 2)
  }

  @inlinable
  init(area: CGFloat) {
    self.a = sqrt(area)
  }
}


// MARK: - Perimeter

public extension Square {
  @inlinable
  var perimeter: CGFloat {
    4 * a
  }

  @inlinable
  init(perimeter: CGFloat) {
    self.a = perimeter / 4
  }
}
