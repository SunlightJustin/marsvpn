//
//  LXBaseNavigationController.swift
//  TableViewRefresher
//
//  Created by clove on 4/24/19.
//  Copyright © 2019 personal.Justin. All rights reserved.
//

import UIKit
import SwifterSwift

class LXBaseNavigationController: UINavigationController {
    
    deinit {
        debugPrint("\(NSStringFromClass(type(of: self))) \(#function)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .backgroundColor
        navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never

        interactivePopGestureRecognizer?.delegate = self
        delegate = self
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if viewControllers.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
            let backItem = UIBarButtonItem(image: UIImage(named: "nv_back")?.withRenderingMode(.alwaysOriginal) , style: .plain, target: viewController, action: #selector(backAction))
//            backItem.tintColor = UIColor(hexString: "#1E1E1E")
            viewController.navigationItem.leftBarButtonItem = backItem
        }

        interactivePopGestureRecognizer?.isEnabled = false
        super.pushViewController(viewController, animated: animated)
    }

    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        interactivePopGestureRecognizer?.isEnabled = false
        return super.popToViewController(viewController, animated: animated)
    }

    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        interactivePopGestureRecognizer?.isEnabled = false
        return super.popToRootViewController(animated: animated)
    }
    
    //MARK: -
    @discardableResult
    fileprivate func popToViewControllerClass(_ aClass: UIViewController.Type, animated: Bool) -> UIViewController? {
        for vc in viewControllers.reversed() {
            if vc.isMember(of: aClass) {
                _ = [super .popToViewController(vc, animated: animated)]
                return vc
            }
        }
        return nil
    }
}

extension UINavigationController {
    
    @discardableResult
    func popToViewController(_ aClass: UIViewController.Type) -> UIViewController? {
        return popToViewController(aClass, animated: true)
    }
    
    @discardableResult
    func popToViewController(_ aClass: UIViewController.Type, animated: Bool) -> UIViewController? {
        guard let nv = self as? LXBaseNavigationController  else {
            assert(true, "popToViewControllerClass is not LXBaseNavigationController")
            return nil
        }
        return nv.popToViewControllerClass(aClass, animated: animated)
    }
}

extension LXBaseNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewControllers.count == 1 {
            interactivePopGestureRecognizer?.isEnabled = false
        } else {
            interactivePopGestureRecognizer?.isEnabled = true
        }
    }
}

extension LXBaseNavigationController: UIGestureRecognizerDelegate {
    internal func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy _: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == interactivePopGestureRecognizer && viewControllers.count == 1 {
            return false
        }
        return true
    }
}

extension UINavigationController {
    open override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }

    open override var childForStatusBarHidden: UIViewController? {
        return topViewController
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
//    public func childViewControllerForStatusBarHidden() -> UIViewController? {
//        return self.visibleViewController
//    }
//
//    public func childViewControllerForStatusBarStyle() -> UIViewController? {
//        return self.visibleViewController
//    }
}

extension UIViewController {
    @objc func backAction() {
        navigationController?.popViewController(animated: true)
    }
}

