//
//  CollectionViewFillLayout+Types.swift
//  StickyLayout
//
//  Created by Karsten Bruns on 29.10.18.
//  Copyright © 2018 bruns.me. All rights reserved.
//

import UIKit

extension CollectionViewFillLayout {

    enum Alignment {
        case `default`
        case flexible
        case stickyBottom
    }

    struct Item<T> {
        let object: T
        let height: CGFloat
        let alignment: Alignment

        init(with object: T, height: CGFloat, alignment: Alignment) {
            self.object = object
            self.height = height
            self.alignment = alignment
        }
    }

    struct Positioning<T> {
        let object: T
        let alignment: Alignment
        var frame: CGRect

        init(for object: T, frame: CGRect, alignment: Alignment) {
            self.object = object
            self.frame = frame
            self.alignment = alignment
        }
    }

    struct Result<T> {
        let positionings: [Positioning<T>]
        let contentSize: CGSize
        let stickyBottomHeight: CGFloat
    }
}
