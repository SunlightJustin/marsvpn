//
//  LXBaseTableViewController.swift
//  TableViewRefresher
//
//  Created by clove on 4/24/19.
//  Copyright © 2019 personal.Justin. All rights reserved.
//

import Foundation

class LXBaseTableViewController: UITableViewController {
    
    convenience init() {
        self.init(style: .plain)
    }
    
    override init(style: UITableView.Style) {
        super.init(style: style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.contentInsetAdjustmentBehavior = .never
//        self.edgesForExtendedLayout = .top;
//        self.extendedLayoutIncludesOpaqueBars = false;

//        Analytics.logEvent(AnalyticsEventSelectContent, parameters: ["View": NSStringFromClass(type(of: self))])
    }
    
    open override var prefersStatusBarHidden: Bool {
        return false
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
