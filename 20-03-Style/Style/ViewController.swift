//
//  ViewController.swift
//  Style
//
//  Created by Karsten Bruns on 29.03.20.
//  Copyright © 2020 bruns.me. All rights reserved.
//

import UIKit



struct Style {
    private let applyStyle: (UIView, StyleSheet) -> Void

    init(_ style: @escaping (UIView, StyleSheet) -> Void) {
        self.applyStyle = style
    }

    func apply(to targetView: UIView, with styleSheet: StyleSheet) {
        applyStyle(targetView, styleSheet)
    }
}


struct StatefulColor {
    var normal: UIColor
    var highlighted: UIColor
    var disabled: UIColor
    var selected: UIColor

    init(normal: UIColor, highlighted: UIColor? = nil, disabled: UIColor? = nil, selected: UIColor? = nil) {
        self.normal = normal
        self.highlighted = highlighted ?? normal
        self.disabled = disabled ?? normal
        self.selected = selected ?? normal
    }

    func color(for state: UIControl.State) -> UIColor {
        if state.contains(.highlighted) {
            return highlighted
        }
        if state.contains(.disabled) {
            return disabled
        }
        if state.contains(.selected) {
            return selected
        }
        return normal
    }
}


struct MatchingColors {
    var background: StatefulColor
    var foreground: StatefulColor
    var weakForeground: StatefulColor
    var separator: StatefulColor

    init(background: StatefulColor, foreground: StatefulColor, weakForeground: StatefulColor? = nil, separator: StatefulColor? = nil) {
        self.foreground = foreground
        self.background = background
        self.weakForeground = weakForeground ?? foreground
        self.separator = separator ?? weakForeground ?? foreground
    }
}


struct ColorSheet {
    var content: MatchingColors
    var actionableContent: MatchingColors
    var action: MatchingColors
}


struct StyleSheet {
    private let colors: ColorSheet

    var mainColorPattern: Style {
        return Style { view, styleSheet in
            self.mainBackgroundColor.apply(to: view, with: styleSheet)
            self.mainTextColor.apply(to: view, with: styleSheet)
        }
    }

    var mainBackgroundColor = Style { view, styleSheet in
        view.backgroundColor = styleSheet.colors.content.background.normal
    }

    var mainTextColor = Style { view, styleSheet in
        switch view {
        case let label as UILabel:
            label.textColor = styleSheet.colors.content.foreground.normal
        default:
            break
        }
    }

    init(colors: ColorSheet) {
        self.colors = colors
    }

    func apply(_ styles: KeyPath<StyleSheet, Style>..., to view: UIView) {
        styles.forEach { style in
            self[keyPath: style].apply(to: view, with: self)
        }
    }
}



class ViewController: UIViewController {
    @IBOutlet var wordLabel: UILabel!

    var styles = StyleSheet(
        colors: ColorSheet(
            content: MatchingColors(
                background: StatefulColor(normal: .black, highlighted: .darkGray),
                foreground: StatefulColor(normal: .white),
                separator: StatefulColor(normal: .darkGray)
            ),
            actionableContent: MatchingColors(
                background: StatefulColor(normal: .black, highlighted: .darkGray),
                foreground: StatefulColor(normal: .white),
                separator: StatefulColor(normal: .darkGray)
            ),
            action: MatchingColors(
                background: StatefulColor(normal: .blue),
                foreground: StatefulColor(normal: .white)
            )
        )
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        styles.apply(\.mainTextColor, \.mainBackgroundColor, to: wordLabel)
    }
}


