import Foundation


public struct QuadraticFunction {
  public let a: CGFloat
  public let b: CGFloat
  public let c: CGFloat

  @inlinable
  public init(a: CGFloat, b: CGFloat, c: CGFloat) {
    self.a = a
    self.b = b
    self.c = c
  }
}


// MARK: - Resolve

public extension QuadraticFunction {
  @inlinable
  func y(forX x: CGFloat) -> CGFloat {
    a * pow(x, 2) + b * x + c
  }

  @inlinable
  func x(forY y: CGFloat) -> (CGFloat, CGFloat) {
    let partialCalc = sqrt((4 * a * (y - c) + pow(b, 2)))
    return (
      (+partialCalc - b) / 2 * a,
      (-partialCalc - b) / 2 * a
    )
  }
}


// MARK: - Derivative

public extension QuadraticFunction {
  @inlinable
  var derivative: LinearFunction {
    LinearFunction(a: 2 * a, b: b)
  }
}


// MARK: - Turning Point

public extension QuadraticFunction {
  @inlinable
  var turningPoint: CGPoint {
    CGPoint(
      x: -(b / (2 * a)),
      y: ((4 * a * c) - pow(b, 2)) / (4 * a)
    )
  }
}


// MARK: - Intercepts

public extension QuadraticFunction {
  @inlinable
  var roots: (CGFloat, CGFloat) {
    let partialCalc1 = -(b / (2 * a))
    let partialCalc2 = sqrt((pow(b, 2) - 4 * a * c) / (4 * pow(a, 2)))
    return (partialCalc1 - partialCalc2, partialCalc1 + partialCalc2)
  }

  var yIntercept: CGFloat {
    y(forX: 0)
  }
}
