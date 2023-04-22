//
//  RootTabBarViewController.swift
//  HugeIndie
//
//  Created by Denny on 2019/9/9.
//  Copyright © 2019 LWJ. All rights reserved.
//

import UIKit

class MVTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .backgroundColor
        self.tabBar.tintColor = .white
//        self.tabBar.barTintColor = .lightBackground
        let array = [
            MVBaseNavigationController(rootViewController: self.fisrtController),
            MVBaseNavigationController(rootViewController: self.settingController),
        ]
        self.setViewControllers(array, animated: false)
        self.selectedIndex = 0
    }

    lazy var fisrtController: MVHomeViewController = {
        let control = MVHomeViewController()
        control.tabBarItem = UITabBarItem.init(title: "Home", image: UIImage(named: "tab_0_normal")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage.init(named: "tab_0_selected")?.withRenderingMode(.alwaysOriginal))
        return control
    }()
    
    lazy var settingController: MVProfielViewController = {
        let control = MVProfielViewController()
        control.tabBarItem = UITabBarItem.init(title: "Account", image: UIImage.init(named: "tab_1_normal")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage.init(named: "tab_1_selected")?.withRenderingMode(.alwaysOriginal))
        return control
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
}
