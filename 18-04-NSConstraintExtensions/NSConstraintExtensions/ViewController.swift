//
//  ViewController.swift
//  NSConstraintExtensions
//
//  Created by Karsten Bruns on 07.04.18.
//  Copyright © 2018 bruns.me. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var redView = UIView()
    private lazy var blueView = UIView()

    private lazy var viewConstraints = [
        redView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
        redView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, priority: .defaultLow),
        redView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
        redView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
        redView.heightAnchor.constraint(equalToConstant: 0, activationRule: .firstInvisible),

        blueView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, priority: .defaultLow),
        blueView.topAnchor.constraintEqualToSystemSpacingBelow(redView.bottomAnchor, multiplier: 1, activationRule: .bothVisible),
        blueView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
        blueView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
        blueView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
        blueView.heightAnchor.constraint(equalTo: redView.heightAnchor, activationRule: .bothVisible),
        blueView.heightAnchor.constraint(equalToConstant: 0, activationRule: .firstInvisible)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        view.setNeedsUpdateConstraints()
    }

    private func addSubviews() {
        view.layoutMargins = UIEdgeInsetsMake(15, 15, 15, 15)
        
        redView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapGesture)))
        redView.backgroundColor = .red
        redView.layer.cornerRadius = 5
        redView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(redView)
        
        blueView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapGesture)))
        blueView.backgroundColor = .blue
        blueView.layer.cornerRadius = 5
        blueView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blueView)
    }

    override func updateViewConstraints() {
        NSLayoutConstraint.evaluateConstraints(viewConstraints, delegate: self)
        super.updateViewConstraints()
    }
    
    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        UIView.animate(withDuration: 1/3) { [weak self] in
            guard let redView = self?.redView, let blueView = self?.blueView else { return }
            
            if gesture.view == blueView {
                if redView.alpha == 0 {
                    redView.alpha = 1
                } else {
                    blueView.alpha = 0
                }
            }
            
            if gesture.view == redView {
                if blueView.alpha == 0 {
                    blueView.alpha = 1
                } else {
                    redView.alpha = 0
                }
            }

            self?.view.setNeedsUpdateConstraints()
            self?.view.layoutIfNeeded()
        }
    }
}

extension ViewController: LayoutConstraintDelegate {
    func shouldActivateConstraint(_ constraint: NSLayoutConstraint) -> Bool {
        return true
    }
}
