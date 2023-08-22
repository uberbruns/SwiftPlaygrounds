import Foundation


// MARK: - Right Triangle

public struct RightTriangle: Equatable {
  public let a: CGFloat
  public let b: CGFloat
  public let c: CGFloat

  @inlinable
  public init(a: CGFloat, b: CGFloat) {
    self.a = a
    self.b = b
    self.c = Pythagoras(a: a, b: b).c
  }

  @inlinable
  public init(a: CGFloat, c: CGFloat) {
    self.a = a
    self.b = Pythagoras(a: a, c: c).b
    self.c = c
  }

  @inlinable
  public init(b: CGFloat, c: CGFloat) {
    self.a = Pythagoras(b: b, c: c).a
    self.b = b
    self.c = c
  }
}


extension RightTriangle: TriangleConvertible {
  public func convertToTriangle() -> Triangle {
    Triangle(a: a, b: b, c: c)
  }
}


// MARK: - Angles

public extension RightTriangle {
  @inlinable
  var alpha: Angle {
    .radians(asin(a / c))
  }

  @inlinable
  var beta: Angle {
    .radians(Angle.degrees(90).radians - alpha.radians)
  }

  @inlinable
  init(a: CGFloat, alpha: Angle) {
    let c = a / sin(alpha.radians)
    self.a = a
    self.b = Pythagoras(a: a, c: c).b
    self.c = c
  }

  @inlinable
  init(b: CGFloat, alpha: Angle) {
    let beta = Angle.degrees(90).radians - alpha.radians
    let c = b / sin(beta)
    self.a = Pythagoras(b: b, c: c).a
    self.b = b
    self.c = c
  }

  @inlinable
  init(c: CGFloat, alpha: Angle) {
    let a = c * sin(alpha.radians)
    self.a = a
    self.b = Pythagoras(a: a, c: c).b
    self.c = c
  }

  @inlinable
  init(a: CGFloat, beta: Angle) {
    let alpha = Angle.degrees(90).radians - beta.radians
    let c = a / sin(alpha)
    self.a = a
    self.b = Pythagoras(a: a, c: c).b
    self.c = c
  }

  @inlinable
  init(b: CGFloat, beta: Angle) {
    let c = b / sin(beta.radians)
    self.a = Pythagoras(b: b, c: c).a
    self.b = b
    self.c = c
  }

  @inlinable
  init(c: CGFloat, beta: Angle) {
    let alpha = Angle.degrees(90).radians - beta.radians
    let a = c * sin(alpha)
    self.a = a
    self.b = Pythagoras(a: a, c: c).b
    self.c = c
  }
}


// MARK: - Area

public extension RightTriangle {
  @inlinable
  var area: CGFloat {
    a * b / 2
  }

  @inlinable
  init(alpha: Angle, area: CGFloat) {
    self = Self(b: (area / 2) / tan(alpha.radians), alpha: alpha)
  }

  @inlinable
  init(beta: Angle, area: CGFloat) {
    self = Self(alpha: .degrees(90 - beta.degrees), area: area)
  }
}


// MARK: - Height

public extension RightTriangle {
  @inlinable
  var height: CGFloat {
    let p = pow(a, 2) / c
    let q = c - p
    return sqrt(p * q)
  }

  @inlinable
  init(a: CGFloat, height: CGFloat) {
    let helperTriangle = RightTriangle(b: height, c: a)
    self = RightTriangle(a: a, beta: helperTriangle.beta)
  }

  @inlinable
  init(b: CGFloat, height: CGFloat) {
    let helperTriangle = RightTriangle(b: height, c: b)
    self = RightTriangle(b: b, alpha: helperTriangle.beta)
  }

  @inlinable
  init(height: CGFloat, alpha: Angle) {
    let helperTriangle = RightTriangle(b: height, beta: alpha)
    self = RightTriangle(b: helperTriangle.c, alpha: alpha)
  }

  @inlinable
  init(height: CGFloat, beta: Angle) {
    let helperTriangle = RightTriangle(b: height, beta: beta)
    self = RightTriangle(a: helperTriangle.c, beta: beta)
  }
}


// MARK: - Perimeter

public extension RightTriangle {
  @inlinable
  var perimeter: CGFloat {
    a + b + c
  }

  @inlinable
  init(a: CGFloat, b: CGFloat, perimeter: CGFloat) {
    self.a = a
    self.b = b
    self.c = perimeter - a - b
  }

  @inlinable
  init(a: CGFloat, c: CGFloat, perimeter: CGFloat) {
    self.a = a
    self.b = perimeter - a - c
    self.c = c
  }

  @inlinable
  init(b: CGFloat, c: CGFloat, perimeter: CGFloat) {
    self.a = perimeter - b - c
    self.b = b
    self.c = c
  }
}
