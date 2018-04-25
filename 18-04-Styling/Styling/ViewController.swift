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
    let styleView: StylingOperation
    init(_ operation: @escaping StylingOperation) {
        self.styleView = operation
    }
}


extension UIView {
    func applyStyles(_ stylings: Styling...) {
        applyStyles(stylings)
    }
    
    
    func applyStyles(_ stylings: [Styling]) {
        for styling in stylings {
            styling.styleView(self)
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
        view.layer.cornerRadius = 40
    }

    static let glow = Styling { view in
        view.layer.shadowColor = UIColor.yellow.cgColor
        view.layer.shadowRadius = 20
        view.layer.shadowOffset = CGSize(width: 0, height: 5)
        view.layer.shadowOpacity = 0.5
    }

    static let glowHighlighted = Styling { view in
        view.layer.shadowColor = UIColor.purple.cgColor
    }

    
    static let bordered = Styling { view in
        view.layer.borderColor = UIColor.orange.cgColor
        view.layer.borderWidth = 2
    }
    
    
    static let borderedHighlighted = Styling { view in
        view.layer.borderColor = UIColor.purple.cgColor
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
        view.applyStyles(.defaultBackground)
        
        testView.addStyle(for: .normal, .buttonBackground, .rounded, .bordered, .glow)
        testView.addStyle(for: .highlighted, .buttonBackgroundHighlighted, .borderedHighlighted, .glowHighlighted)
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
    
    
    func addStyle(for controlState: UIControlState, _ stylings: Styling...) {
        stateStylings[controlState.rawValue] = stylings
        setNeedsLayout()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if isHighlighted, let highlightStyles = stateStylings[UIControlState.highlighted.rawValue] {
            applyStyles(highlightStyles)
        } else if let normalStyles = stateStylings[UIControlState.normal.rawValue] {
            applyStyles(normalStyles)
        }
    }
}
