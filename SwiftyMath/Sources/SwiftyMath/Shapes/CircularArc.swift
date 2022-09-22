import Foundation


public struct CircularArc {
  public let centralAngle: Angle
  public let radius: CGFloat

  @inlinable
  init(centralAngle: Angle, radius: CGFloat) {
    self.centralAngle = centralAngle
    self.radius = radius
  }
}


// MARK: Diameter

public extension CircularArc {
  @inlinable
  var diameter: CGFloat {
    radius * 2
  }

  @inlinable
  init(centralAngle: Angle, diameter: CGFloat) {
    self.centralAngle = centralAngle
    self.radius = diameter / 2
  }
}


// MARK: Sector Area

public extension CircularArc {
  @inlinable
  var sectorArea: CGFloat {
    pow(radius, 2) * centralAngle.radians / 2
  }

  @inlinable
  init(centralAngle: Angle, sectorArea: CGFloat) {
    self.centralAngle = centralAngle
    self.radius = sqrt(sectorArea / centralAngle.radians * 2)
  }
}


// MARK: Arc Length

public extension CircularArc {
  @inlinable
  var arcLength: CGFloat {
    radius * centralAngle.radians
  }

  @inlinable
  init(radius: CGFloat, arcLength: CGFloat) {
    self.centralAngle = .radians(arcLength / radius)
    self.radius = radius
  }

  @inlinable
  init(diameter: CGFloat, arcLength: CGFloat) {
    self = Self.init(radius: diameter / 2, arcLength: arcLength)
  }
}


// MARK: Chord Length

public extension CircularArc {
  @inlinable
  var chordLength: CGFloat {
    RightTriangle(c: radius, alpha: .radians(centralAngle.radians / 2)).a * 2
  }
}
