//
//  UIViewControllerExtensions.swift
//  HugeIndie
//
//  Created by Denny on 2019/9/9.
//  Copyright © 2019 LWJ. All rights reserved.
//

import UIKit
extension UIViewController {
    func addContainerViewController(_ child: UIViewController?, on view: UIView) {
        guard let child = child else { return }
        child.willMove(toParent: self)
        addChild(child)
        view.addSubview(child.view)
        child.view.frame = CGRect(origin: .zero, size: view.frame.size)
        child.didMove(toParent: self)
    }
    
    func removeContainerViewController(_ child: UIViewController?, from _: UIView) {
        guard let child = child else { return }
        dismiss(with: child)
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
    
    private func dismiss(with child: UIViewController?) {
        guard let child = child else { return }
        child.navigationController?.popToRootViewController(animated: false)
        if let presentedVc = child.presentedViewController {
            dismiss(with: presentedVc)
            presentedVc.dismiss(animated: presentedVc.presentedViewController == nil, completion: nil)
        }
    }
}

extension UIViewController {
    func setCustomNavigationTitle(with title: String, font: UIFont? = .boldSystemFont(ofSize: 16), titleColor: UIColor? = .white, kern: Int? = 0) -> UILabel {
        let titleLabel = UILabel()
        if let font = font, let titleColor = titleColor, let kern = kern {
            let attributes = NSAttributedString(string: title, attributes: [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: titleColor, NSAttributedString.Key.kern: kern])
            titleLabel.attributedText = attributes
            titleLabel.textAlignment = .center
            titleLabel.sizeToFit()
            navigationItem.titleView = titleLabel
        }
        return titleLabel
    }
}

extension UIViewController {
    static func topMostController() -> UIViewController? {
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        if let rootViewController = rootViewController,
            let nextViewController = nextVisibleViewControllerOnViewController(rootViewController) {
            return nextViewController
        }
        return rootViewController
    }
    
    static func nextVisibleViewControllerOnViewController(_ inViewController: UIViewController) -> UIViewController? {
        var inViewController: UIViewController? = inViewController
        while inViewController?.presentedViewController != nil {
            inViewController = inViewController?.presentedViewController
        }
        
        if let tabBarController = inViewController as? UITabBarController,
            let selectedViewController = tabBarController.selectedViewController {
            return nextVisibleViewControllerOnViewController(selectedViewController)
        }
        
        if let navigationController = inViewController as? UINavigationController,
            let visibleViewController = navigationController.visibleViewController {
            return nextVisibleViewControllerOnViewController(visibleViewController)
        }
        
        return inViewController
    }
}

enum ViewTransitionType {
    case none
    case push
    case present
}

protocol ViewTransitionProtocal: NSObjectProtocol {
    func toViewController(_ viewController: UIViewController, transitionType: ViewTransitionType, animated: Bool)
    func addViewController(_ viewController: UIViewController)
    func removFromSuperController()
    func addViewControllerWithPresentTransition(_ viewController: UIViewController, duration: TimeInterval)
    func removFromSuperControllerWithPresentTransition(withDuration duration: TimeInterval)
}

extension ViewTransitionProtocal where Self: UIViewController {
    func toViewController(_ viewController: UIViewController, transitionType: ViewTransitionType, animated: Bool) {
        switch transitionType {
        case .none: addViewController(viewController)
        case .push: navigationController?.pushViewController(viewController, animated: animated)
        case .present: present(viewController, animated: animated, completion: nil)
        }
    }
    func addViewController(_ viewController: UIViewController) {
        addChild(viewController)
        view.addSubview(viewController.view)
    }
    func removFromSuperController() {
        removeFromParent()
        view.removeFromSuperview()
    }
    func addViewControllerWithPresentTransition(_ viewController: UIViewController, duration: TimeInterval) {
        addViewController(viewController)
        viewController.view.frame = CGRect.init(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        UIView.animate(withDuration: duration) {
            viewController.view.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        }
    }
    func removFromSuperControllerWithPresentTransition(withDuration duration: TimeInterval) {
        view.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        UIView.animate(withDuration: duration, animations: { [weak self] in
            self?.view.frame = CGRect.init(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
            }, completion: { [weak self] (complete) in
                self?.removFromSuperController()
                if !complete {
                }
        })
    }
}

extension UIViewController: ViewTransitionProtocal {}

extension UIViewController {
    @objc func uiDescription() -> String {
        let fullName = NSStringFromClass(type(of: self))
        let name = fullName.components(separatedBy: ".").last ?? fullName
        return name.removingSuffix("Controller").removingSuffix("View")
    }
    
    
}

