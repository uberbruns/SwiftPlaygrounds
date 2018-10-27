//
//  LayoutResolver.swift
//  StickyLayout
//
//  Created by Karsten Bruns on 26.10.18.
//  Copyright © 2018 bruns.me. All rights reserved.
//

import UIKit

enum FillLayout {

    enum Alignment {
        case top
        case flexible
        case bottom
    }

    struct Item<T> {
        fileprivate let object: T
        fileprivate let height: CGFloat
        fileprivate let alignment: Alignment

        init(with object: T, height: CGFloat, alignment: Alignment) {
            self.object = object
            self.height = height
            self.alignment = alignment
        }
    }

    struct Positioning<T> {
        let object: T
        let alignment: Alignment
        fileprivate(set) var frame: CGRect

        init(for object: T, frame: CGRect, alignment: Alignment) {
            self.object = object
            self.frame = frame
            self.alignment = alignment
        }
    }

    struct Result<T> {
        let positionings: [Positioning<T>]
        let contentSize: CGSize
    }

    static func solve<S:BidirectionalCollection, T>(with items: S, inside bounds: CGRect, offset: CGFloat) -> Result<T> where S.Element == Item<T>, S.Index == Int {
        var positionings = [Positioning<T>]()

        var lastTopFrame = CGRect(x: bounds.minX, y: bounds.minY - offset, width: bounds.width, height: 0)
        var lastBottomFrame = CGRect(x: bounds.minX, y: bounds.maxY, width: bounds.width, height: 0)

        var combinedHeight = CGFloat(0)
        var combinedBottomHeight = CGFloat(0)

        var firstFlexiblePositioning: Int?
        var flexiblePositioningCount = CGFloat(0)
        var bottomPositionings = [Int]()

        for (index, item) in items.enumerated() {
            let positioning: Positioning<T>
            let height = item.height

            switch item.alignment {
            case .top, .flexible:
                let y = lastTopFrame.maxY
                let frame = CGRect(x: bounds.minX, y: y, width: bounds.width, height: height)
                positioning = Positioning(for: item.object, frame: frame, alignment: item.alignment)
                lastTopFrame = frame
                if item.alignment == .flexible {
                    flexiblePositioningCount += 1
                    if firstFlexiblePositioning == nil {
                        firstFlexiblePositioning = index
                    }
                }
            case .bottom:
                let y = lastBottomFrame.maxY
                let frame = CGRect(x: bounds.minX, y: y, width: bounds.width, height: height)
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
            let freeSpace = bounds.height - combinedHeight
            if freeSpace > 0 {
                let extraHeightPerItem = freeSpace / flexiblePositioningCount
                var additionalY = CGFloat(0)
                for index in firstFlexiblePositioning..<items.endIndex {
                    let item = items[index]

                    // Skip bottom alignments
                    if item.alignment == .bottom {
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
            contentSize = CGSize(width: bounds.width, height: max(bounds.height, combinedHeight))
        } else {
            contentSize = CGSize(width: bounds.width, height: combinedHeight)
        }

        // Move bottom items up
        for index in bottomPositionings {
            positionings[index].frame.origin.y -= combinedBottomHeight
        }

        return Result(positionings: positionings, contentSize: contentSize)
    }
}
