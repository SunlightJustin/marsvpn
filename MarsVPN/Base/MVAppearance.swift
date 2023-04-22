//
//  NOAppearanceConfig.swift
//  Nano
//
//  Created by clove on 3/19/22.
//

import Foundation
import UIKit

class MVAppearance {
    static func appearanceConfig() {
//        UIBarButtonItem.appearance().tintColor = .lightTheme
//        UIBarButtonItem.appearance().setTitleTextAttributes([.font : UIFont.boldRamblaFont(ofSize: 17)], for: .normal)
      
        
        let navigationBar = UINavigationBar.appearance()
//        navigationBar.scrollEdgeAppearance = {
//            let appearance = UINavigationBarAppearance()
//            appearance.backgroundColor = .backgroundColor
//            appearance.titleTextAttributes = [.foregroundColor: UIColor(hexString: "#FFFFFF")!,
//                                                 .font: UIFont.mediumSystemFont(ofSize: 18)]
//            return appearance
//        }()
//
//        navigationBar.standardAppearance = {
//            let appearance = UINavigationBarAppearance()
//            appearance.backgroundColor = .backgroundColor
//            appearance.titleTextAttributes = [.foregroundColor: UIColor(hexString: "#FFFFFF")!,
//                                                 .font: UIFont.mediumSystemFont(ofSize: 18)]
//            return appearance
//        }()
//
//        navigationBar.titleTextAttributes = [.foregroundColor: UIColor(hexString: "#FFFFFF")!,
//                                             .font: UIFont.mediumSystemFont(ofSize: 18)]
//        navigationBar.isTranslucent = false
//        navigationBar.barTintColor = .backgroundColor
//        navigationBar.setBackgroundImage(UIImage(), for: .default)
//        navigationBar.shadowImage = UIImage()
        
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.shadowColor = .clear
        appearance.backgroundColor = .backgroundColor
        appearance.backgroundImage = UIImage()
        appearance.shadowImage = UIImage()
        appearance.titleTextAttributes = [.foregroundColor: UIColor(hexString: "#FFFFFF")!, .font: UIFont.boldMontserratFont(ofSize: 20)]
        
        navigationBar.isTranslucent = false
        navigationBar.compactAppearance = appearance
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.backgroundColor = appearance.backgroundColor
        
        let tabAppearance = UITabBarAppearance()
        tabAppearance.backgroundImage = UIImage()
        tabAppearance.shadowImage = UIImage()
        tabAppearance.configureWithTransparentBackground()
        
        let tabbar = UITabBar.appearance()
        tabbar.standardAppearance = tabAppearance
    }
}
