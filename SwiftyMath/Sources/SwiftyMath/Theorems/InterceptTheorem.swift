import Foundation


public struct InterceptTheorem {
  public struct SolvedLine {
    public let firstSegment: CGFloat
    public let secondSegment: CGFloat

    @inlinable
    public var sum: CGFloat {
      firstSegment + secondSegment
    }

    @inlinable
    public init(firstSegment: CGFloat, secondSegment: CGFloat) {
      self.firstSegment = firstSegment
      self.secondSegment = secondSegment
    }

    @inlinable
    public static func segmentLength(first: CGFloat, second: CGFloat) -> Self {
      return Self.init(
        firstSegment: first,
        secondSegment: second
      )
    }

    @inlinable
    public static func segmentLength(first: CGFloat, sum: CGFloat) -> Self {
      return Self.init(
        firstSegment: first,
        secondSegment: sum - first
      )
    }

    @inlinable
    public static func segmentLength(second: CGFloat, sum: CGFloat) -> Self {
      return Self.init(
        firstSegment: sum - second,
        secondSegment: second
      )
    }
  }

  public struct UnsolvedLine {
    public let type: `Type`

    public enum `Type` {
      case firstSegment(CGFloat)
      case secondSegment(CGFloat)
      case sum(CGFloat)
    }

    @inlinable
    public init(type: `Type`) {
      self.type = type
    }

    @inlinable
    public static func segmentLength(first: CGFloat) -> Self {
      Self(type: .firstSegment(first))
    }

    @inlinable
    public static func segmentLength(second: CGFloat) -> Self {
      Self(type: .secondSegment(second))
    }

    @inlinable
    public static func sum(_ sum: CGFloat) -> Self {
      Self(type: .sum(sum))
    }
  }

  public let knownLine: SolvedLine
  public let solvedLine: SolvedLine

  @inlinable
  public init(knownLine: SolvedLine, unsolvedLine: UnsolvedLine) {
    self.knownLine = knownLine
    
    switch unsolvedLine.type {
    case .firstSegment(let value):
      self.solvedLine = .segmentLength(
        first: value,
        second: (knownLine.secondSegment / knownLine.firstSegment) * value
      )
    case .secondSegment(let value):
      self.solvedLine = .segmentLength(
        first: (knownLine.firstSegment / knownLine.secondSegment) * value,
        second: value
      )
    case .sum(let value):
      self.solvedLine = .segmentLength(
        first: (knownLine.firstSegment / knownLine.sum) * value,
        sum: value
      )
    }
  }
}

