import Foundation


@inlinable
public func translate(_ value: CGFloat, from: ClosedRange<CGFloat>, to: ClosedRange<CGFloat>) -> CGFloat {
  let fromLength = from.upperBound - from.lowerBound
  let toLength = to.upperBound - to.lowerBound
  let progress = (value - from.lowerBound) / fromLength
  return to.lowerBound + (toLength * progress)
}


@inlinable
public func clamp(_ value: CGFloat, to: ClosedRange<CGFloat>) -> CGFloat {
  return max(min(value, to.upperBound), to.lowerBound)
}


@inlinable
public func clamp(_ value: CGFloat, to: PartialRangeFrom<CGFloat>) -> CGFloat {
  return max(value, to.lowerBound)
}


@inlinable
public func clamp(_ value: CGFloat, to: PartialRangeThrough<CGFloat>) -> CGFloat {
  return min(value, to.upperBound)
}
