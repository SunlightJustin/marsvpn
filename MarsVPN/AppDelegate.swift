//
//  AppDelegate.swift
//  MarsVPN
//
//  Created by Justin on 2022/11/22.
//

import UIKit
//import FirebaseCore
//import FirebaseFirestore
import Flurry_iOS_SDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        MVVPNTool.shared
        MVAppearance.appearanceConfig()
        MVIAPManager.setupIAP()
        
        // vip will cache node
        if MVConfigModel.isVIP() {
            MVDataManager.fetchLocationListWhenAppLauching()
        } else {
            MVDataManager.fetchLocationList { _, _ in }
        }
        
        // App config will set free days vip
        MVDataManager.fetchAppConfig()
        
        MVIAPManager.checkPurchaseIfCanMakePayments()

        window = UIWindow(frame: UIScreen.main.bounds)
        guard let window = window else { return false }
        let MVMainViewController = MVMainViewController()
        window.rootViewController = MVMainViewController
        window.makeKeyAndVisible()
        window.overrideUserInterfaceStyle = .light
        
        
        let builder = FlurrySessionBuilder.init()
        builder.build(crashReportingEnabled: true)
        builder.build(logLevel: .none)
        builder.build(appVersion: AppInfo.version)
        Flurry.set(userId: AppInfo.shortDeviceId)
        Flurry.set(appVersion: AppInfo.version)
        builder.build(sessionProperties: ["UserID" : AppInfo.shortDeviceId])
        if MVConfigModel.ensuredVIP() {
            builder.build(sessionProperties: ["VIPUID" : AppInfo.shortDeviceId])
            GGAnalyticsManager.logEvent("ensuredVIP", event1: "shortDeviceId", value: AppInfo.shortDeviceId)
        }
        Flurry.startSession(apiKey: "54JYT6SR7H4KCYP7G6B9", sessionBuilder: builder)
                
        return true
    }

}

extension UIApplication {
    var firstWindowScene: UIWindowScene? {
        UIApplication.shared.connectedScenes
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })
    }
}
