//
//  MVWebViewController.swift
//  GOGOVPN
//
//  Created by Justin on 2022/6/23.
//

import Foundation

class MVWebViewController: LXBaseWebViewController {
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    open override var prefersStatusBarHidden: Bool {
        return false
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
