//
//  AppDelegate.swift
//  VarNavBar
//
//  Created by Karsten Bruns on 19/07/16.
//  Copyright © 2016 Karsten Bruns. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? = UIWindow()


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let viewController = ViewController()
        let navigationController = NavigationController(rootViewController: viewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        return true
    }
}


class NavigationController : UINavigationController, UINavigationControllerDelegate {

    let navigationBarBackgroundView = UIView()

    private var navigationBarFrame: CGRect? {
        didSet {
            if navigationBarFrame != oldValue {
               updateBackgroundView()
            }
        }
    }


    private func updateBackgroundView(viewController viewController: UIViewController) {
        if let viewController = viewController as? ViewController {
            self.navigationBarBackgroundView.frame.size.height = navigationBar.frame.maxY + viewController.navigationBarBackgroundHeight
        }
    }


    func updateBackgroundView() {
        if let viewController = topViewController {
            updateBackgroundView(viewController: viewController)
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.setBackgroundImage(UIImage(named: "blank"), forBarMetrics: .Default)
        navigationBar.shadowImage = UIImage(named: "blank")
        navigationBar.tintColor = .whiteColor()
        delegate = self

        if let barSuperView = navigationBar.superview {
            navigationBarBackgroundView.frame.size.width = view.frame.width
            navigationBarBackgroundView.backgroundColor = .darkGrayColor()
            navigationBarBackgroundView.autoresizingMask = [.FlexibleWidth, .FlexibleBottomMargin]
            barSuperView.insertSubview(navigationBarBackgroundView, belowSubview: navigationBar)
        }
    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationBarFrame = navigationBar.frame
    }


    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        transitionCoordinator()?.animateAlongsideTransitionInView(navigationBar.superview, animation: { (context) in
            self.updateBackgroundView(viewController: viewController)
        }, completion: { (context) in })
    }
}


class ViewController : UIViewController {

    var alternative = false

    var navigationBarBackgroundHeight: CGFloat {
        return alternative ? (3 * 44) : 0
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        if alternative {
            view.backgroundColor = .lightGrayColor()
            title = "Han"
        } else {
            view.backgroundColor = .grayColor()
            title = "Solo"
        }

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(push(_:)))
        view.addGestureRecognizer(tapGestureRecognizer)
    }


    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }


    @objc func push(sender: AnyObject) {
        let nextViewController = ViewController()
        nextViewController.alternative = !alternative
        showViewController(nextViewController, sender: self)
    }
}
