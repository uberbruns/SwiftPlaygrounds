//
//  LayoutResolver.swift
//  StickyLayout
//
//  Created by Karsten Bruns on 26.10.18.
//  Copyright © 2018 bruns.me. All rights reserved.
//

import UIKit

enum Alignment {
    case leadingEdge
    case leadingSpace
    case trailingEdge
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

        var lastLeadingPositioning = Positioning(element: Void(), frame: CGRect(x: bounds.minX, y: bounds.minY - offset, width: bounds.width, height: 0))
        var lastTrailingPositioning = Positioning(element: Void(), frame: CGRect(x: bounds.minX, y: bounds.maxY, width: bounds.width, height: 0))

        var combinedHeight = CGFloat(0)
        var combinedTrailingHeight = CGFloat(0)

        var firstSpaciousPositioning: Int?
        var spaciousPositioningCount = CGFloat(0)
        var trailingEdgePositionings = [Int]()

        for (index, parameter) in parameters.enumerated() {
            let positioning: Positioning
            let height = parameter.height

            switch parameter.alignment {
            case .leadingEdge, .leadingSpace:
                let y = lastLeadingPositioning.frame.maxY
                let frame = CGRect(x: bounds.minX, y: y, width: bounds.width, height: height)
                positioning = Positioning(element: parameter.element, frame: frame)
                lastLeadingPositioning = positioning
                if parameter.alignment == .leadingSpace {
                    spaciousPositioningCount += 1
                    if firstSpaciousPositioning == nil {
                        firstSpaciousPositioning = index
                    }
                }
            case .trailingEdge:
                let y = lastTrailingPositioning.frame.maxY
                let frame = CGRect(x: bounds.minX, y: y, width: bounds.width, height: height)
                positioning = Positioning(element: parameter.element, frame: frame)
                combinedTrailingHeight += height
                lastTrailingPositioning = positioning
                trailingEdgePositionings.append(index)
            }

            positionings.append(positioning)
            combinedHeight += height
        }

        if let firstSpaciousPositioning = firstSpaciousPositioning {
            let combinedSpacing = bounds.height - combinedHeight
            if combinedSpacing > 0 {
                let spacing = combinedSpacing / spaciousPositioningCount
                var additionalY = CGFloat(0)
                for index in firstSpaciousPositioning..<parameters.endIndex {
                    let parameter = parameters[index]
                    if parameter.alignment == .trailingEdge {
                        continue
                    }
                    positionings[index].frame.origin.y += additionalY
                    if parameter.alignment == .leadingSpace {
                        positionings[index].frame.origin.y += spacing
                        additionalY += spacing
                    }
                }
            }
        }

        for index in trailingEdgePositionings {
            positionings[index].frame.origin.y -= combinedTrailingHeight
        }

        return positionings
    }
}
