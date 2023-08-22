import Foundation


public struct LinearFunction {
  public let a: CGFloat
  public let b: CGFloat

  @inlinable
  public init(a: CGFloat, b: CGFloat) {
    self.a = a
    self.b = b
  }

  @inlinable
  public init(slope: CGFloat, yIntercept: CGFloat) {
    self.a = slope
    self.b = yIntercept
  }
}


// MARK: - Resolve

public extension LinearFunction {
  @inlinable
  func y(forX x: CGFloat) -> CGFloat {
    (a * x) + b
  }

  @inlinable
  func x(forY y: CGFloat) -> CGFloat {
    (y - b) / a
  }
}


// MARK: - Angle

public extension LinearFunction {
  @inlinable
  var angle: Angle {
    Angle.radians(atan(a))
  }

  @inlinable
  init(angle: Angle, b: CGFloat) {
    self.a = tan(angle.radians)
    self.b = b
  }
}


// MARK: - Points

public extension LinearFunction {
  @inlinable
  init(firstPoint: CGPoint, secondPoint: CGPoint) {
    let rise = secondPoint.y - firstPoint.y
    let run = secondPoint.x - firstPoint.x
    let slope = rise / run
    self.a = slope
    self.b = firstPoint.y - slope * firstPoint.x
  }

  @inlinable
  init(a: CGFloat, point: CGPoint) {
    self.a = a
    self.b = point.y - a * point.x
  }

  @inlinable
  init(angle: Angle, point: CGPoint) {
    self.a = tan(angle.radians)
    self.b = point.y - a * point.x
  }
}


// MARK: - Point of Intersection

public extension LinearFunction {
  @inlinable
  func pointOfIntersection(with otherFunction: LinearFunction) -> CGPoint {
    let x = (otherFunction.b - b) / (a - otherFunction.a)
    let y = y(forX: x)
    return CGPoint(x: x, y: y)
  }
}


// MARK: - Intercepts

public extension LinearFunction {
  @inlinable
  var root: CGFloat {
    x(forY: 0)
  }

  var yIntercept: CGFloat {
    b
  }
}
