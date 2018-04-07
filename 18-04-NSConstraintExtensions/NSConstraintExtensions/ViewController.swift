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

    private lazy var constraints = [
        redView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, identifier: "redView.top"),
        redView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, identifier: "~redView.bottom.whenBlueViewIsHidden", priority: .defaultLow),
        redView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor, identifier: "redView.left"),
        redView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor, identifier: "redView.right"),
        redView.heightAnchor.constraint(equalToConstant: 0, identifier: ".redView.bottom"),

        blueView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, identifier: "blueView.top.whenRedViewIsHidden", priority: .defaultLow),
        blueView.topAnchor.constraintEqualToSystemSpacingBelow(redView.bottomAnchor, multiplier: 1, identifier: "~blueView.top"),
        blueView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, identifier: "blueView.bottom"),
        blueView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor, identifier: "blueView.left"),
        blueView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor, identifier: "blueView.right"),
        blueView.heightAnchor.constraint(equalTo: redView.heightAnchor, identifier: "~blueView.height"),
        blueView.heightAnchor.constraint(equalToConstant: 0, identifier: ".blueView.height"),
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
        NSLayoutConstraint.toggleConstraints(constraints)
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

