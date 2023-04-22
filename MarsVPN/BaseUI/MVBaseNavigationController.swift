//
//  MVBaseNavigationController.swift
//  GOGOVPN
//
//  Created by Justin on 2022/6/23.
//

import Foundation


class MVBaseNavigationController: LXBaseNavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .backgroundColor
        navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor(hexString: "#FFFFFF")!,
                                                  .font: UIFont.mediumSystemFont(ofSize: 18)]

//        navigationBar.titleTextAttributes = [.foregroundColor: UIColor(hexString: "#FFFFFF")!,
//                                             .font: UIFont.regularEczarFont(ofSize: 24)]
//        navigationBar.isTranslucent = false
//        navigationBar.shadowImage = UIImage()
        
//        self.setNavigationBarHidden(false, animated: false)
//        self.navigationBar.isTranslucent = true
//        self.navigationBar.setBackgroundImage(nil, for: .default)
//        self.navigationBar.shadowImage = nil
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        
//
//        let appearance = UINavigationBarAppearance()
//        appearance.configureWithDefaultBackground()
//        appearance.shadowColor = .clear
//        appearance.backgroundColor = .backgroundColor
//        appearance.backgroundImage = UIImage()
//        appearance.shadowImage = UIImage()
//        appearance.titleTextAttributes = [.foregroundColor: UIColor(hexString: "#FFFFFF")!, .font: UIFont.mediumSystemFont(ofSize: 18)]
//
//        self.navigationController?.navigationBar.isTranslucent = false
//        self.navigationController?.navigationBar.compactAppearance = appearance
//        self.navigationController?.navigationBar.standardAppearance = appearance
//        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
//        self.navigationController?.navigationBar.backgroundColor = appearance.backgroundColor
    }

    
}
