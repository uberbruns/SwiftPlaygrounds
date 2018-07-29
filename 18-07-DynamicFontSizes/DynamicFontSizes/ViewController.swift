//
//  ViewController.swift
//  DynamicFontSizes
//
//  Created by Karsten Bruns on 28.07.18.
//  Copyright © 2018 Karsten Bruns. All rights reserved.
//

import UIKit


struct Style {
    let name: String
    let textStyle: UIFont.TextStyle

    var pointSize: CGFloat {
        return UIFont.preferredFont(forTextStyle: textStyle).pointSize
    }
}


class ViewController: UIViewController {

    let styles = [
        Style(name: "largeTitle", textStyle: .largeTitle),
        Style(name: "title1", textStyle: .title1),
        Style(name: "title2", textStyle: .title2),
        Style(name: "title3", textStyle: .title3),
        Style(name: "headline", textStyle: .headline),
        Style(name: "subheadline", textStyle: .subheadline),
        Style(name: "body", textStyle: .body),
        Style(name: "callout", textStyle: .callout),
        Style(name: "footnote", textStyle: .footnote),
        Style(name: "caption1", textStyle: .caption1),
        Style(name: "caption2", textStyle: .caption2)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        titleLabel.font = titleLabel.font.withSize(22).withAdjustedSize(contentSizeCategory: traitCollection.preferredContentSizeCategory)
        bodyLabel.font = bodyLabel.font.withSize(18).withAdjustedSize(contentSizeCategory: traitCollection.preferredContentSizeCategory)

        /*
        print("UIContentSizeCategory(rawValue: \"" + traitCollection.preferredContentSizeCategory.rawValue + "\"): [")
        for style in styles {
            print(".\(style.name): \(style.pointSize),")
        }
        print("],")
         */
    }
}




