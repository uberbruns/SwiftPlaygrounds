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
                                                    safeArea: UIEdgeInsets = .zero) -> Result<T> where S.Element == Item<T>, S.Index == Int {
        var positionings = [Positioning<T>]()

        let x = bounds.minX + safeArea.left
        let width = bounds.width - safeArea.left - safeArea.right
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
            case .stickyBottom:
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
            let availableHeight = bounds.height - safeArea.top - safeArea.bottom
            let freeSpace = availableHeight - combinedHeight
            if freeSpace > 0 {
                let extraHeightPerItem = freeSpace / flexiblePositioningCount
                var additionalY = CGFloat(0)
                for index in firstFlexiblePositioning..<items.endIndex {
                    let item = items[index]

                    // Skip bottom alignments
                    if item.alignment == .stickyBottom {
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
                    return 0
                }
            }
            return offset
        }()

        // Move bottom items up
        for index in bottomPositionings {
            positionings[index].frame.origin.y = positionings[index].frame.origin.y
                + bounds.maxY
                - safeArea.bottom
                - combinedBottomHeight
                + validatedOffset
        }

        return Result(positionings: positionings,
                      contentSize: contentSize,
                      stickyBottomHeight: combinedBottomHeight)
    }
}