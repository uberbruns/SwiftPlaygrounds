import Foundation


public struct Circle {
  public let radius: CGFloat

  @inlinable
  public init(radius: CGFloat) {
    self.radius = radius
  }
}


// MARK: - Diameter

public extension Circle {
  @inlinable
  var diameter: CGFloat {
    radius * 2
  }


  @inlinable
  init(diameter: CGFloat) {
    self.radius = diameter / 2
  }
}


// MARK: - Area

public extension Circle {
  @inlinable
  var area: CGFloat {
    .pi * pow(radius, 2)
  }


  @inlinable
  init(area: CGFloat) {
    radius = sqrt(area / .pi)
  }
}


// MARK: - Circumference

public extension Circle {
  @inlinable
  var circumference: CGFloat {
    2 * .pi * radius
  }


  @inlinable
  init(circumference: CGFloat) {
    radius = circumference / (2 * .pi)
  }
}



// MARK: - Coordinates

public extension Circle {
  func coordinates(forAngle angle: Angle) -> CGPoint {
    CGPoint(
      x: radius * cos(angle.radians),
      y: radius * sin(angle.radians)
    )
  }

  @inlinable
  init(coordinates: CGPoint) {
    radius = Pythagoras(a: coordinates.x, b: coordinates.y).c
  }
}
