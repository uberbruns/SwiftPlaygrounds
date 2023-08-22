//
//  main.swift
//  KVOValues
//
//  Created by Karsten Bruns on 14.04.23.
//

import Foundation


extension AsyncStream {
  /// Initializes a new ``AsyncStream`` and an ``AsyncStream/Continuation``.
  ///
  /// - Parameters:
  ///   - elementType: The element type of the stream.
  ///   - limit: The buffering policy that the stream should use.
  /// - Returns: A tuple containing the stream and its continuation. The continuation should be passed to the
  /// producer while the stream should be passed to the consumer.
  public static func makeStream(
    of elementType: Element.Type = Element.self,
    bufferingPolicy limit: Continuation.BufferingPolicy = .unbounded
  ) -> (stream: AsyncStream<Element>, continuation: AsyncStream<Element>.Continuation) {
    var continuation: AsyncStream<Element>.Continuation!
    let stream = AsyncStream<Element>(bufferingPolicy: limit) { continuation = $0 }
    return (stream: stream, continuation: continuation!)
  }
}



