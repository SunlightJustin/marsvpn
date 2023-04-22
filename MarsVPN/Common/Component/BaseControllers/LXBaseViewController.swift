//
//  BaseViewController.swift
//  BaseViewControllerSwift
//
//  Created by Aaron McTavish on 06/01/2016.
//  Copyright © 2016 ustwo Fampany Ltd. All rights reserved.
//

import UIKit

/// Generic base view controller that automatically loads the underlying `BaseView` of type `T`.
open class LXBaseViewController: UIViewController {
    

//    // MARK: - Properties
//
//    /// The view managed by the view controller typed by the `BaseViewController` generic.
//    open var underlyingView: T {
//        if let myView = view as? T {
//            return myView
//        }
//
//        let newView = T()
//        view = newView
//        return newView
//    }
//
//
//    // MARK: - Initializers
//
//    public init() {
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required public init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
////        fatalError("init(coder:) has not been implemented")
//    }
//
//    // MARK: - View Lifecycle
//
//    open override func loadView() {
//        view = T()
//        if view.isMember(of: UIView.self) {
//            view.backgroundColor = UIColor.white
//        }
//    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
//        Analytics.logEvent(AnalyticsEventSelectContent, parameters: ["View": NSStringFromClass(type(of: self))])
        
        view.overrideUserInterfaceStyle = .light

        setupView()
        setupAccessibility()
    }
    
    
    // MARK: - Setup
    
    /// Abstract method. Subclasses should override this method to setup their view.
    open func setupView() {
        
    }
    
    /// Abstract method. Subclasses should override this method to add accessibility.
    open func setupAccessibility() {
        
    }
    
    open override var prefersStatusBarHidden: Bool {
        return false
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
