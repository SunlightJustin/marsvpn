//
//  BaseWebViewController.swift
//  SDM
//
//  Created by clove on 1/5/19.
//  Copyright © 2019 personal.Justin. All rights reserved.
//

import Foundation
import ProgressWebViewController

class LXBaseWebViewController: ProgressWebViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.disableZoom = true
        self.websiteTitleInNavigationBar = false
        self.toolbarItemTypes = []
        
        self.edgesForExtendedLayout = .top
        self.extendedLayoutIncludesOpaqueBars = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    open override var prefersStatusBarHidden: Bool {
        return false
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
