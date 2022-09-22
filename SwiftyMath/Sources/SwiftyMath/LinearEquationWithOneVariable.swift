import Foundation


public struct LinearEquationWithOneVariable {
  public let a: CGFloat
  public let b: CGFloat

  @inlinable
  public init(a: CGFloat, b: CGFloat) {
    precondition(a != 0, "Parameter `a` is not allowed to be zero.")
    self.a = a
    self.b = b
  }
}


// MARK: - X

public extension LinearEquationWithOneVariable {
  @inlinable
  var x: CGFloat {
    -b / a
  }

  init(x: CGFloat, a: CGFloat) {
    self.a = a
    self.b = -a * x
  }

  init(x: CGFloat, b: CGFloat) {
    self.a = -b / x
    self.b = b
  }
}

