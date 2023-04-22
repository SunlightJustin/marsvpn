//
//  ViewController.swift
//  Kinker
//
//  Created by clove on 7/13/20.
//  Copyright © 2020 personal.Justin. All rights reserved.
//

import UIKit
import SwiftyJSON
import Reachability
import CoreTelephony.CTCellularData

let SAFE_AREA_TOP = UIApplication.shared.firstWindowScene?.statusBarManager?.statusBarFrame.height ?? 0
    
extension MVMainViewController {
    public class func loginTransition() {
        let vc = UIApplication.shared.keyWindow?.rootViewController as! MVMainViewController
        vc.loginTransition()
    }
    
    public class func logoutTransition() {
        if let vc = UIApplication.shared.keyWindow?.rootViewController as? MVMainViewController {
            vc.logoutTransition()
        }
    }
}

class MVMainViewController: LXBaseViewController {
    var _isShowing = false
    var _isShownAgreement = MVConfigModel.isShownAgreement
    
//        var disposeBag = DisposeBag()

        var _guideNavigationController : LXBaseNavigationController?
        var _homeViewController : UIViewController?
        
        var guideNavigationController: LXBaseNavigationController {
            get {
                if _guideNavigationController != nil {
                    return _guideNavigationController!
                } else {
//                    let sb = UIStoryboard(name: "Register", bundle: Bundle.main)
                    let vc = MVGuideVC()
                    _guideNavigationController = LXBaseNavigationController(rootViewController:vc)
                    self.addChild(_guideNavigationController!)
                    return _guideNavigationController!
                }
            }
        }
        
        var homeViewController: UIViewController {
            get {
                if _homeViewController != nil {
                    return _homeViewController!
                } else {
                    let vc = MVTabBarController()
//                    let vc = UIViewController(nibName: nil, bundle: nil)
                    vc.view.backgroundColor = .red
                    _homeViewController = vc
                    self.addChild(_homeViewController!)
                    return _homeViewController!
                }
            }
        }
    
    lazy var launchScreen: UIViewController = {
        let sb = UIStoryboard(name: "LaunchScreen", bundle: Bundle.main)
        let vc = sb.instantiateViewController(identifier: "MVLaunchScreen")
        return vc
    }()
    
        public func logoutTransition() {
            guard let vc = _homeViewController else { return }
            
            UIView.transition(from: vc.view,
                              to: self.guideNavigationController.view,
                              duration: 0.5,
                              options: .transitionCrossDissolve) { _ in
                                self.removeHomeVC()
            }
        }
        
        public func loginTransition() {
            // will remove no wanner animate
            self.view.addSubview(self.homeViewController.view)
            
            UIView.transition(from: self.guideNavigationController.view,
                              to: self.homeViewController.view,
                              duration: 0.5,
                              options: .transitionCrossDissolve) { _ in
                                self.removeGuideNV()
            }
        }
    

        override func viewDidLoad() {
            super.viewDidLoad()

            view.backgroundColor = .backgroundColor

//            if MVConfigModel.isShownAgreement == false || (User.current?.isVip() == false &&  MVConfigModel.isShownPurchaseGuideToday == false) {
//            if (!MVConfigModel.isVIP() && !MVConfigModel.isShownPurchaseGuideToday) {
            if (!MVConfigModel.isVIP()) {
                // 自动获取必要数据
                MVIAPManager.fetchProduct1 { reuslt in
                    self.view.addSubview(self.guideNavigationController.view)
                    self.hideLauchScreenIfNeeded()
                }
//                GGDataManager.autologinAndProduct1 {
//                    self.hideLauchScreenIfNeeded()
//                }
            } else {
                self.view.addSubview(self.homeViewController.view)
//                // 自动获取必要数据
//                GGDataManager.autologinAndLocations {
//
//                    //为 MVVPNTool.shared 获取数据延时
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.hideLauchScreenIfNeeded()
                    }
//                }
            }
            
            showLauchScreen()
            
            // 获取数据超时跳过
            DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                self.hideLauchScreenIfNeeded()
            }

            registerReachability()
//            #endif
        }
        
        func removeHomeVC() {
            _homeViewController?.removeFromParent()
            _homeViewController?.view.removeFromSuperview()
            _homeViewController = nil
        }
        
        func removeGuideNV() {
            _guideNavigationController?.removeFromParent()
            _guideNavigationController?.view.removeFromSuperview()
            _guideNavigationController = nil
        }
    
    private func showAdsIfNeeded() {
       
    }
    
    func showAdsWhenDidBecomeActive() {
        
    }
    
    private func hideLauchScreenIfNeeded() {
        if MVConfigModel.isVIP() {
            hideLauchScreen()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                if self._isShowing {
                    
                } else {
                    self.hideLauchScreen()
                }
            }
        }
    }
    
    private func showLauchScreen() {
        let vc = self.launchScreen
        vc.view.backgroundColor = .cyan
        self.view.addSubview(vc.view)
        self.addChild(vc)
    }
    
    private func hideLauchScreen() {
        UIView.animate(withDuration: 0.25) {
            self.launchScreen.view.alpha = 0
        } completion: { _ in
            self.launchScreen.view.removeFromSuperview()
            self.launchScreen.removFromSuperController()
        }
    }
    
    private func hideLauchScreenFromAds() {
        self.launchScreen.view.alpha = 0

        self.launchScreen.view.removeFromSuperview()
        self.launchScreen.removFromSuperController()
    }
    
    let reachability = try! Reachability()
    func registerReachability() {

//        let reachability = try! Reachability()

        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                debugPrint("Reachable via WiFi")
            } else {
                debugPrint("Reachable via Cellular")
            }
        }
        reachability.whenUnreachable = { [weak self] _ in
            debugPrint("Network not reachable")
            if CTCellularData().restrictedState != .restrictedStateUnknown {
                presentReEnableNativePopup(title: "Network not reachable", message: "", allowButtonTitle: nil, denyButtonTitle: "OK")
            }
        }

        do {
            try reachability.startNotifier()
        } catch {
            debugPrint("Unable to start notifier")
        }
    }
    
}



//extension MVMainViewController: AdsProtocol {
//    func didLoadAd() {
//        showAdsIfNeeded()
//    }
//    func adDidDismissFullScreenContent() {
////        self.hideLauchScreenFromAds()
//        _isShowing = false
//    }
//}
