//
//  LayoutResolver.swift
//  StickyLayout
//
//  Created by Karsten Bruns on 26.10.18.
//  Copyright © 2018 bruns.me. All rights reserved.
//

import UIKit

extension CollectionViewFillLayout {

    static func solve<S:BidirectionalCollection, T>(with items: S,
                                                    inside bounds: CGRect,
                                                    offset: CGFloat,
                                                    clipOffset: Bool = false,
                                                    contentInsets: UIEdgeInsets = .zero) -> Result<T> where S.Element == Item<T>, S.Index == Int {
        var positionings = [Positioning<T>]()

        let x = CGFloat(0)
        let width = bounds.width - contentInsets.left - contentInsets.right
        var lastTopFrame = CGRect(x: x, y: bounds.minY, width: width, height: 0)
        var lastBottomFrame = CGRect(x: x, y: 0, width: width, height: 0)

        var combinedHeight = CGFloat(0)
        var combinedBottomHeight = CGFloat(0)

        var firstFlexiblePositioning: Int?
        var flexiblePositioningCount = CGFloat(0)
        var bottomPositionings = [Int]()

        for (index, item) in items.enumerated() {
            let positioning: Positioning<T>
            let height = item.height

            switch item.alignment {
            case .default, .flexible:
                let y = lastTopFrame.maxY
                let frame = CGRect(x: x, y: y, width: width, height: height)
                positioning = Positioning(for: item.object, frame: frame, alignment: item.alignment)
                lastTopFrame = frame
                if item.alignment == .flexible {
                    flexiblePositioningCount += 1
                    if firstFlexiblePositioning == nil {
                        firstFlexiblePositioning = index
                    }
                }
            case .pinnedToBottom:
                let y = lastBottomFrame.maxY
                let frame = CGRect(x: x, y: y, width: width, height: height)
                positioning = Positioning(for: item.object, frame: frame, alignment: item.alignment)
                combinedBottomHeight += height
                lastBottomFrame = frame
                bottomPositionings.append(index)
            }

            positionings.append(positioning)
            combinedHeight += height
        }

        // Change size and positions due flexible alignments
        let contentSize: CGSize
        if let firstFlexiblePositioning = firstFlexiblePositioning {
            let availableHeight = bounds.height - contentInsets.top - contentInsets.bottom
            let freeSpace = availableHeight - combinedHeight
            if freeSpace > 0 {
                let extraHeightPerItem = freeSpace / flexiblePositioningCount
                var additionalY = CGFloat(0)
                for index in firstFlexiblePositioning..<items.endIndex {
                    let item = items[index]

                    // Skip bottom alignments
                    if item.alignment == .pinnedToBottom {
                        continue
                    }

                    // All other positionings are moved
                    positionings[index].frame.origin.y += additionalY

                    // Flexible alignments gain extra height
                    if item.alignment == .flexible {
                        positionings[index].frame.size.height += extraHeightPerItem
                        additionalY += extraHeightPerItem
                    }
                }
            }
            contentSize = CGSize(width: width, height: max(availableHeight, combinedHeight))
        } else {
            contentSize = CGSize(width: width, height: combinedHeight)
        }

        // Validate offset to avoid layout issues on complete layout invalidattion that create
        // invalid content offsets. For example when the content is scrolled all the way down
        // and items are removed.
        let validatedOffset = { () -> CGFloat in
            if clipOffset {
                let maxOffset = contentSize.height - bounds.height
                if offset > maxOffset {
                    return maxOffset
                } else if offset < 0 {
                    return 0 - contentInsets.top - contentInsets.bottom
                }
            }
            return offset - contentInsets.bottom
        }()

        // Move bottom items up
        for index in bottomPositionings {
            positionings[index].frame.origin.y = positionings[index].frame.origin.y
                + bounds.maxY
                - combinedBottomHeight
                + validatedOffset
        }

        return Result(positionings: positionings,
                      contentSize: contentSize,
                      stickyBottomHeight: combinedBottomHeight)
    }
}
