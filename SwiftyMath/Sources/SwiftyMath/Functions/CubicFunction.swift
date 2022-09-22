import Foundation


public struct CubicFunction {
  public let a: CGFloat
  public let b: CGFloat
  public let c: CGFloat
  public let d: CGFloat

  @inlinable
  public init(a: CGFloat, b: CGFloat, c: CGFloat, d: CGFloat) {
    self.a = a
    self.b = b
    self.c = c
    self.d = d
  }
}


// MARK: - Resolve

public extension CubicFunction {
  @inlinable
  func y(forX x: CGFloat) -> CGFloat {
    a * pow(x, 3) + b * pow(x, 2) + c * x + d
  }

  @inlinable
  func x(forY y: CGFloat) -> (CGFloat, CGFloat?, CGFloat?) {
    // Via https://math.stackexchange.com/questions/1581633/how-can-i-solve-for-x-values-of-a-cubic-function-where-x-intersects-a-given
    func positiveCubed(_ value: CGFloat) -> CGFloat {
      let oneThird = 1 / 3.0
      return (value < 0) ? -pow(-value, oneThird) : pow(value, oneThird)
    }

    let squaredB = b * b
    let q = (3.0 * c - squaredB) / 9.0
    let r = (-27.0 * d + b * (9.0 * c - 2.0 * squaredB)) / 54.0
    let cubicQ = q * q * q
    let discriminator = cubicQ + r * r
    let term1 = b / 3.0

    if discriminator > 0 {
      // One real, two complex roots
      let discriminatorSquareRoot = sqrt(discriminator)
      let root = -term1 + positiveCubed(r + discriminatorSquareRoot) + positiveCubed(r - discriminatorSquareRoot)
      return (root, nil, nil)
    } else if discriminator == 0 {
      // Three real, two of them equal
      let cubedR = positiveCubed(r)

      let firstXIntercept = (-term1 + cubedR * 2.0)
      let secondXIntercept = (-cubedR - term1)

      if firstXIntercept < secondXIntercept {
        return (firstXIntercept, secondXIntercept, nil)
      } else {
        return (secondXIntercept, firstXIntercept, nil)
      }
    } else {
      let term2 = 2.0 * sqrt(-q)
      let term3 = acos(r / sqrt(-cubicQ))

      let firstXIntercept  = (-term1 + term2 * cos(term3 / 3))
      let secondXIntercept = (-term1 + term2 * cos((term3 + 2 * .pi) / 3))
      let thirdXIntercept  = (-term1 + term2 * cos((term3 + 4 * .pi) / 3))

      let sortedIntercepts = [firstXIntercept, secondXIntercept, thirdXIntercept].sorted()
      return (sortedIntercepts[0], sortedIntercepts[1], sortedIntercepts[2])
    }
  }
}


// MARK: - Derivative

public extension CubicFunction {
  @inlinable
  var derivative: QuadraticFunction {
    QuadraticFunction(a: 3 * a, b: 2 * b, c: c)
  }
}


// MARK: - Turning Points

public extension CubicFunction {
  @inlinable
  var turningPoints: (CGPoint, CGPoint) {
    let (x1, x2) = derivative.roots
    let y1 = y(forX: x1)
    let y2 = y(forX: x2)
    return (
      CGPoint(x: x1, y: y1),
      CGPoint(x: x2, y: y2)
    )
  }
}


// MARK: - Inflection Point

public extension CubicFunction {
  @inlinable
  var inflectionPoint: CGPoint {
    let x = derivative.derivative.x(forY: 0)
    let y = y(forX: x)
    return CGPoint(x: x, y: y)
  }
}


// MARK: - Intercepts

public extension CubicFunction {
  @inlinable
  var roots: (CGFloat, CGFloat?, CGFloat?) {
    let roots = x(forY: 0)
    return (
      roots.0,
      roots.1,
      roots.2
    )
  }

  var yIntercept: CGFloat {
    y(forX: 0)
  }
}
