//
//  LayoutResolver.swift
//  StickyLayout
//
//  Created by Karsten Bruns on 26.10.18.
//  Copyright © 2018 bruns.me. All rights reserved.
//

import UIKit

enum Alignment {
    case top
    case flexibleSize
    case bottom
}

struct Parameter {
    let element: Any
    let height: CGFloat
    let alignment: Alignment
}

struct Positioning {
    var element: Any
    var frame: CGRect
}

struct Resolver {
    func resolve(parameters: [Parameter], bounds: CGRect, offset: CGFloat) -> [Positioning] {
        var positionings = [Positioning]()

        var lastTopPositioning = Positioning(element: Void(), frame: CGRect(x: bounds.minX, y: bounds.minY - offset, width: bounds.width, height: 0))
        var lastBottomPositioning = Positioning(element: Void(), frame: CGRect(x: bounds.minX, y: bounds.maxY, width: bounds.width, height: 0))

        var combinedHeight = CGFloat(0)
        var combinedBottomHeight = CGFloat(0)

        var firstFlexiblePositioning: Int?
        var flexiblePositioningCount = CGFloat(0)
        var bottomPositionings = [Int]()

        for (index, parameter) in parameters.enumerated() {
            let positioning: Positioning
            let height = parameter.height

            switch parameter.alignment {
            case .top, .flexibleSize:
                let y = lastTopPositioning.frame.maxY
                let frame = CGRect(x: bounds.minX, y: y, width: bounds.width, height: height)
                positioning = Positioning(element: parameter.element, frame: frame)
                lastTopPositioning = positioning
                if parameter.alignment == .flexibleSize {
                    flexiblePositioningCount += 1
                    if firstFlexiblePositioning == nil {
                        firstFlexiblePositioning = index
                    }
                }
            case .bottom:
                let y = lastBottomPositioning.frame.maxY
                let frame = CGRect(x: bounds.minX, y: y, width: bounds.width, height: height)
                positioning = Positioning(element: parameter.element, frame: frame)
                combinedBottomHeight += height
                lastBottomPositioning = positioning
                bottomPositionings.append(index)
            }

            positionings.append(positioning)
            combinedHeight += height
        }

        if let firstFlexiblePositioning = firstFlexiblePositioning {
            let freeSpace = bounds.height - combinedHeight
            if freeSpace > 0 {
                let extraHeightPerItem = freeSpace / flexiblePositioningCount
                var additionalY = CGFloat(0)
                for index in firstFlexiblePositioning..<parameters.endIndex {
                    let parameter = parameters[index]

                    // Skip bottom alignments
                    if parameter.alignment == .bottom {
                        continue
                    }

                    // All other positionings are moved
                    positionings[index].frame.origin.y += additionalY

                    // Flexible alignments gain extra height
                    if parameter.alignment == .flexibleSize {
                        positionings[index].frame.size.height += extraHeightPerItem
                        additionalY += extraHeightPerItem
                    }
                }
            }
        }

        for index in bottomPositionings {
            positionings[index].frame.origin.y -= combinedBottomHeight
        }

        return positionings
    }
}
