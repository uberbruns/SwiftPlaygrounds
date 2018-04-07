//
//  ViewController.swift
//  Styling
//
//  Created by Karsten Bruns on 07.04.18.
//  Copyright © 2018 bruns.me. All rights reserved.
//

import UIKit


struct Styling {
    typealias StylingOperation = (UIView) -> ()
    let style: StylingOperation
    init(_ style: @escaping StylingOperation) {
        self.style = style
    }
}


extension UIView {
    func style(_ stylings: Styling...) {
        style(stylings)
    }
    
    
    func style(_ stylings: [Styling]) {
        for styling in stylings {
            styling.style(self)
        }
    }
}


extension Styling {
    static let defaultBackground = Styling { view in
        if let layer = view.layer as? CAGradientLayer {
            layer.colors = [UIColor.darkGray.cgColor, UIColor.black.cgColor]
        } else {
            view.backgroundColor = .black
        }
    }

    static let buttonBackground = Styling { view in
        if let layer = view.layer as? CAGradientLayer {
            layer.colors = [UIColor.yellow.cgColor, UIColor.orange.cgColor]
        } else {
            view.backgroundColor = .orange
        }
    }

    static let buttonBackgroundHighlighted = Styling { view in
        if let layer = view.layer as? CAGradientLayer {
            layer.colors = [UIColor.red.cgColor, UIColor.purple.cgColor]
        } else {
            view.backgroundColor = .purple
        }
    }

    static let rounded = Styling { view in
        view.layer.cornerRadius = 8
    }

    static let bordered = Styling { view in
        view.layer.borderColor = UIColor.orange.cgColor
        view.layer.borderWidth = 2
    }
    
    static let borderedHighlighted = Styling { view in
        view.layer.borderColor = UIColor.purple.cgColor
        view.layer.borderWidth = 2
    }
}


class ViewController: UIViewController {
    
    private lazy var testView = GradientButton()
    
    override func loadView() {
        view = GradientView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        addConstraints()
    }
    
    func addSubviews() {
        view.style(.defaultBackground)
        
        testView.style(for: .normal, .buttonBackground, .rounded, .bordered)
        testView.style(for: .highlighted, .buttonBackgroundHighlighted, .borderedHighlighted)
        testView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(testView)
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            testView.widthAnchor.constraint(equalToConstant: 200),
            testView.heightAnchor.constraint(equalToConstant: 200),
            testView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            testView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}


class GradientView: UIView {
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
}


class GradientButton: UIButton {
    
    override var isHighlighted: Bool {
        didSet {
            setNeedsLayout()
        }
    }
    
    private(set) var stateStylings = [UInt: [Styling]]()
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    func style(for controlState: UIControlState, _ stylings: Styling...) {
        stateStylings[controlState.rawValue] = stylings
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if isHighlighted, let highlightStyles = stateStylings[UIControlState.highlighted.rawValue] {
            style(highlightStyles)
        } else if let normalStyles = stateStylings[UIControlState.normal.rawValue] {
            style(normalStyles)
        }
    }
}
