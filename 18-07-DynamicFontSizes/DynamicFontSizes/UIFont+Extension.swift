//
//  UIFont+Extension.swift
//  DynamicFontSizes
//
//  Created by Karsten Bruns on 28.07.18.
//  Copyright © 2018 Karsten Bruns. All rights reserved.
//

import UIKit

private let table: [UIContentSizeCategory: [UIFont.TextStyle: CGFloat]] = [
    .extraSmall: [
        .largeTitle: 31,
        .title1: 25,
        .title2: 19,
        .title3: 17,
        .headline: 14,
        .subheadline: 12,
        .body: 14,
        .callout: 13,
        .footnote: 12,
        .caption1: 11,
        .caption2: 11,
    ],
    .small: [
        .largeTitle: 32,
        .title1: 26,
        .title2: 20,
        .title3: 18,
        .headline: 15,
        .subheadline: 13,
        .body: 15,
        .callout: 14,
        .footnote: 12,
        .caption1: 11,
        .caption2: 11,
    ],
    .medium: [
        .largeTitle: 33,
        .title1: 27,
        .title2: 21,
        .title3: 19,
        .headline: 16,
        .subheadline: 14,
        .body: 16,
        .callout: 15,
        .footnote: 12,
        .caption1: 11,
        .caption2: 11,
    ],
    .large: [
        .largeTitle: 34,
        .title1: 28,
        .title2: 22,
        .title3: 20,
        .headline: 17,
        .subheadline: 15,
        .body: 17,
        .callout: 16,
        .footnote: 13,
        .caption1: 12,
        .caption2: 11,
    ],
    .extraLarge: [
        .largeTitle: 36,
        .title1: 30,
        .title2: 24,
        .title3: 22,
        .headline: 19,
        .subheadline: 17,
        .body: 19,
        .callout: 18,
        .footnote: 15,
        .caption1: 14,
        .caption2: 13,
    ],
    .extraExtraLarge: [
        .largeTitle: 38,
        .title1: 32,
        .title2: 26,
        .title3: 24,
        .headline: 21,
        .subheadline: 19,
        .body: 21,
        .callout: 20,
        .footnote: 17,
        .caption1: 16,
        .caption2: 15,
    ],
    .extraExtraExtraLarge: [
        .largeTitle: 40,
        .title1: 34,
        .title2: 28,
        .title3: 26,
        .headline: 23,
        .subheadline: 21,
        .body: 23,
        .callout: 22,
        .footnote: 19,
        .caption1: 18,
        .caption2: 17,
    ],
    .accessibilityMedium: [
        .largeTitle: 44,
        .title1: 38,
        .title2: 34,
        .title3: 31,
        .headline: 28,
        .subheadline: 25,
        .body: 28,
        .callout: 26,
        .footnote: 23,
        .caption1: 22,
        .caption2: 20,
    ],
    .accessibilityLarge: [
        .largeTitle: 48,
        .title1: 43,
        .title2: 39,
        .title3: 37,
        .headline: 33,
        .subheadline: 30,
        .body: 33,
        .callout: 32,
        .footnote: 27,
        .caption1: 26,
        .caption2: 24,
    ],
    .accessibilityExtraLarge: [
        .largeTitle: 52,
        .title1: 48,
        .title2: 44,
        .title3: 43,
        .headline: 40,
        .subheadline: 36,
        .body: 40,
        .callout: 38,
        .footnote: 33,
        .caption1: 32,
        .caption2: 29,
    ],
    .accessibilityExtraExtraLarge: [
        .largeTitle: 56,
        .title1: 53,
        .title2: 50,
        .title3: 49,
        .headline: 47,
        .subheadline: 42,
        .body: 47,
        .callout: 44,
        .footnote: 38,
        .caption1: 37,
        .caption2: 34,
    ],
    .accessibilityExtraExtraExtraLarge: [
        .largeTitle: 60,
        .title1: 58,
        .title2: 56,
        .title3: 55,
        .headline: 53,
        .subheadline: 49,
        .body: 53,
        .callout: 51,
        .footnote: 44,
        .caption1: 43,
        .caption2: 40,
    ]
]

extension UIFont {
    func withAdjustedSize(correspondingTo textStyle: UIFont.TextStyle, in contentSizeCategory: UIContentSizeCategory) -> UIFont {
        guard let systemReferenceSize = table[.large]?[textStyle],
            let systemCategorySize = table[contentSizeCategory]?[textStyle]
            else { fatalError()
        }

        let factor = systemCategorySize / systemReferenceSize
        let newSize = round(pointSize * factor)
        return withSize(newSize)
    }

    func withAdjustedSize(contentSizeCategory: UIContentSizeCategory) -> UIFont {
        return withSize(adjustedPointSize(contentSizeCategory: contentSizeCategory))
    }

    private func adjustedPointSize(contentSizeCategory: UIContentSizeCategory) -> CGFloat {
        // Categorie Ranges
        let smallCategories: [UIContentSizeCategory] = [.large, .medium, .small, .extraSmall]
        let largeCategories: [UIContentSizeCategory] = [.large, .extraLarge, .extraExtraLarge, .extraExtraExtraLarge]
        let accessibilityCategories: [UIContentSizeCategory] = [.extraExtraExtraLarge, .accessibilityMedium, .accessibilityLarge, .accessibilityExtraLarge, .accessibilityExtraExtraLarge, .accessibilityExtraExtraExtraLarge]

        // Corner Values
        let smallStartRange: (CGFloat, CGFloat) = (9, 31)
        let largeStartRange: (CGFloat, CGFloat) = (11, 34)
        let largeEndRange: (CGFloat, CGFloat) = (13, 36)
        let accessibilityEndRange: (CGFloat, CGFloat) = (40, 60)

        // Calculate new point size
        let newPointSize: CGFloat

        if let index = smallCategories.index(of: contentSizeCategory) {
            let progress = CGFloat(index) / CGFloat(smallCategories.count)
            newPointSize = pointSize.interpolated(startMin: largeStartRange.0,
                                                  startMax: largeStartRange.1,
                                                  endMin: smallStartRange.0,
                                                  endMax: smallStartRange.1,
                                                  progress: progress)

        } else if let index = largeCategories.index(of: contentSizeCategory) {
            let progress = CGFloat(index) / CGFloat(largeCategories.count)
            newPointSize = pointSize.interpolated(startMin: largeStartRange.0,
                                                  startMax: largeStartRange.1,
                                                  endMin: largeEndRange.0,
                                                  endMax: largeEndRange.1,
                                                  progress: progress)

        } else if let index = accessibilityCategories.index(of: contentSizeCategory) {
            let extraExtraExtraLargePointSize = adjustedPointSize(contentSizeCategory: .extraExtraExtraLarge)
            let progress = CGFloat(index) / CGFloat(largeCategories.count)
            newPointSize = extraExtraExtraLargePointSize.interpolated(
                startMin: largeEndRange.0,
                startMax: largeEndRange.1,
                endMin: accessibilityEndRange.0,
                endMax: accessibilityEndRange.1,
                progress: progress)

        } else {
            newPointSize = pointSize
        }

        return round(newPointSize)
    }
}


private extension CGFloat {
    func interpolated(startMin: CGFloat, startMax: CGFloat, endMin: CGFloat, endMax: CGFloat, progress: CGFloat) -> CGFloat {
        let startProgress = asRelativeValueInRange(startMin, startMax)
        let endValue = endMin.progressing(byRelativeValue: startProgress, to: endMax)
        return progressing(byRelativeValue: progress, to: endValue)
    }

    func asRelativeValueInRange(_ from: CGFloat, _ to: CGFloat) -> CGFloat {
        return (self - from) / (to - from)
    }

    func progressing(byRelativeValue progress: CGFloat, to: CGFloat) -> CGFloat {
        return self + ((to - self) * progress)
    }
}
