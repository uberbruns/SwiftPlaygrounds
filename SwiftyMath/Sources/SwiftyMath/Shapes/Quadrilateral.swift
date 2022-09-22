import Foundation


public struct Quadrilateral {
  public let a: CGFloat
  public let b: CGFloat
  public let c: CGFloat
  public let d: CGFloat
  public let e: CGFloat
  public let f: CGFloat

  @inlinable
  public init(
    a: CGFloat,
    b: CGFloat,
    c: CGFloat,
    d: CGFloat,
    e: CGFloat,
    f: CGFloat
  ) {
    self.a = a
    self.b = b
    self.c = c
    self.d = d
    self.e = e
    self.f = f
  }
}


// MARK: - `QuadrilateralConvertible` Conformance

extension Quadrilateral: QuadrilateralConvertible {
  public func convertToQuadrilateral() -> Quadrilateral {
    Quadrilateral(a: a, b: b, c: c, d: d, e: e, f: f)
  }
}


// MARK: - Angles

public extension Quadrilateral {
  @inlinable
  init(
    a: CGFloat,
    b: CGFloat,
    c: CGFloat,
    d: CGFloat,
    alpha: Angle,
    beta: Angle
  ) {
    self.a = a
    self.b = b
    self.c = c
    self.d = d
    self.e = sqrt(pow(a, 2) + pow(b, 2) - 2 * a * b * cos(beta.radians))
    self.f = sqrt(pow(a, 2) + pow(d, 2) - 2 * a * d * cos(alpha.radians))
  }

  @inlinable
  init(
    a: CGFloat,
    b: CGFloat,
    c: CGFloat,
    d: CGFloat,
    alpha: Angle,
    delta: Angle
  ) {
    self.a = a
    self.b = b
    self.c = c
    self.d = d
    self.e = sqrt(pow(d, 2) + pow(d, 2) - 2 * c * d * cos(delta.radians))
    self.f = sqrt(pow(a, 2) + pow(d, 2) - 2 * a * d * cos(alpha.radians))
  }

  @inlinable
  init(
    a: CGFloat,
    b: CGFloat,
    c: CGFloat,
    d: CGFloat,
    beta: Angle,
    gamma: Angle
  ) {
    self.a = a
    self.b = b
    self.c = c
    self.d = d
    self.e = sqrt(pow(a, 2) + pow(b, 2) - 2 * a * b * cos(beta.radians))
    self.f = sqrt(pow(b, 2) + pow(c, 2) - 2 * b * c * cos(gamma.radians))
  }

  @inlinable
  init(
    a: CGFloat,
    b: CGFloat,
    c: CGFloat,
    d: CGFloat,
    delta: Angle,
    gamma: Angle
  ) {
    self.a = a
    self.b = b
    self.c = c
    self.d = d
    self.e = sqrt(pow(d, 2) + pow(d, 2) - 2 * c * d * cos(delta.radians))
    self.f = sqrt(pow(b, 2) + pow(c, 2) - 2 * b * c * cos(gamma.radians))
  }
}


// MARK: - Perimeter

public extension Quadrilateral {
  @inlinable
  init(
    a: CGFloat,
    b: CGFloat,
    c: CGFloat,
    e: CGFloat,
    f: CGFloat,
    perimeter: CGFloat
  ) {
    self.a = a
    self.b = b
    self.c = c
    self.d = perimeter - a - b - c
    self.e = e
    self.f = f
  }

  @inlinable
  init(
    a: CGFloat,
    b: CGFloat,
    d: CGFloat,
    e: CGFloat,
    f: CGFloat,
    perimeter: CGFloat
  ) {
    self.a = a
    self.b = b
    self.c = perimeter - a - b - d
    self.d = d
    self.e = e
    self.f = f
  }

  @inlinable
  init(
    a: CGFloat,
    c: CGFloat,
    d: CGFloat,
    e: CGFloat,
    f: CGFloat,
    perimeter: CGFloat
  ) {
    self.a = a
    self.b = perimeter - a - c - d
    self.c = c
    self.d = d
    self.e = e
    self.f = f
  }

  @inlinable
  init(
    b: CGFloat,
    c: CGFloat,
    d: CGFloat,
    e: CGFloat,
    f: CGFloat,
    perimeter: CGFloat
  ) {
    self.a = perimeter - b - c - d
    self.b = b
    self.c = c
    self.d = d
    self.e = e
    self.f = f
  }
}
