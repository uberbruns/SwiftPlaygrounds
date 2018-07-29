//
//  main.swift
//  DynamicFontSizeCalc
//
//  Created by Karsten Bruns on 28.07.18.
//  Copyright © 2018 Karsten Bruns. All rights reserved.
//

import Foundation

private func adjustedValue(startValue: CGFloat, startMin: CGFloat, startMax: CGFloat, endMin: CGFloat, endMax: CGFloat, progress: CGFloat) -> CGFloat {
    let startProgress = startValue.relativeProgress(from: startMin, to: startMax)
    let endValue = endMin.progressing(byRelativeValue: startProgress, to: endMax)
    return startValue.progressing(byRelativeValue: progress, to: endValue)
}


private extension CGFloat {
    func relativeProgress(from: CGFloat, to: CGFloat) -> CGFloat {
        return (self - from) / (to - from)
    }

    func progressing(byRelativeValue progress: CGFloat, to: CGFloat) -> CGFloat {
        return self + ((to - self) * progress)
    }
}


print(adjustedValue(startValue: 19, startMin: 11, startMax: 34, endMin: 17, endMax: 40, progress: 1))



