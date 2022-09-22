import Foundation


public struct Rectangle {
  public let a: CGFloat
  public let b: CGFloat

  @inlinable
  public init(a: CGFloat, b: CGFloat) {
    self.a = a
    self.b = b
  }
}


// MARK: - `QuadrilateralConvertible` Conformance

extension Rectangle: QuadrilateralConvertible {
  @inlinable
  public var c: CGFloat { a }

  @inlinable
  public var d: CGFloat { b }

  @inlinable
  public var e: CGFloat { diagonal }

  @inlinable
  public var f: CGFloat { diagonal }

  public func convertToQuadrilateral() -> Quadrilateral {
    Quadrilateral(a: a, b: b, c: c, d: d, e: e, f: f)
  }
}


// MARK: - Diagonal

public extension Rectangle {
  @inlinable
  var diagonal: CGFloat {
    Pythagoras(a: a, b: b).c
  }


  @inlinable
  init(a: CGFloat, diagonal: CGFloat) {
    self.a = a
    self.b = Pythagoras(a: a, c: diagonal).b
  }

  @inlinable
  init(b: CGFloat, diagonal: CGFloat) {
    self.a = Pythagoras(b: b, c: diagonal).b
    self.b = b
  }
}


// MARK: - Ratio

public extension Rectangle {
  @inlinable
  var ratio: CGFloat {
    a / b
  }

  @inlinable
  init(a: CGFloat, ratio: CGFloat) {
    self.a = a
    self.b = a / ratio
  }

  @inlinable
  init(b: CGFloat, ratio: CGFloat) {
    self.a = b * ratio
    self.b = b
  }
}


// MARK: - Area

public extension Rectangle {
  @inlinable
  var area: CGFloat {
    a * b
  }

  @inlinable
  init(a: CGFloat, area: CGFloat) {
    self.a = a
    self.b = area / a
  }

  @inlinable
  init(b: CGFloat, area: CGFloat) {
    self.a = area / b
    self.b = b
  }

  @inlinable
  init(ratio: CGFloat, area: CGFloat) {
    let a = sqrt(area * ratio)
    self.a = a
    self.b = area / a
  }
}


// MARK: - Perimeter

public extension Rectangle {
  @inlinable
  var perimeter: CGFloat {
    2 * a + 2 * b
  }

  @inlinable
  init(a: CGFloat, perimeter: CGFloat) {
    self.a = a
    self.b = (perimeter - 2 * a) / 2
  }

  @inlinable
  init(b: CGFloat, perimeter: CGFloat) {
    self.a = (perimeter - 2 * b) / 2
    self.b = b
  }

  @inlinable
  init(ratio: CGFloat, perimeter: CGFloat) {
    let a = perimeter / (2 + 2 / ratio)
    self.a = a
    self.b = a / ratio
  }
}


// MARK: - Ratio

public extension Rectangle {
  @inlinable
  var angle: Angle {
    RightTriangle(a: a, b: b).beta
  }

  @inlinable
  init(a: CGFloat, angle: Angle) {
    self.a = a
    self.b = RightTriangle(a: a, beta: angle).b
  }

  @inlinable
  init(b: CGFloat, angle: Angle) {
    self.a = RightTriangle(b: b, beta: angle).a
    self.b = b
  }

  @inlinable
  init(perimeter: CGFloat, angle: Angle) {
    let ratio = RightTriangle(b: 1, beta: angle).a
    let a = perimeter / (2 + 2 / ratio)
    self.a = a
    self.b = a / ratio
  }

  @inlinable
  init(area: CGFloat, angle: Angle) {
    let triangle = RightTriangle(beta: angle, area: area / 2)
    self.a = triangle.a
    self.b = triangle.b
  }
}
