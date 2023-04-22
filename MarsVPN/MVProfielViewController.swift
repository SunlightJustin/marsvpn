//
//  EditProfileViewController.swift
//  Kinker
//
//  Created by clove on 8/3/20.
//  Copyright © 2020 personal.Justin. All rights reserved.
//

import Foundation
import ActiveLabel

fileprivate enum CellType: String {
    case Account
    case Feedback
    case Settings
    case RateUs
    case FollowUs
    case About
    case Blank

    var title: String {
        switch self {
        case .Account:  return "Localization.Account.account"
        case .Feedback:  return "Feedback"
        case .Settings:  return "Setting"
        case .RateUs:  return "Rate us"
        case .FollowUs:  return "Localization.Account.rateUs"
        case .About:  return "About"
        case .Blank: return ""
        }
    }
    
    var imageName: String? {
        switch self {
        case .Account:  return "icon_account"
        case .Feedback:  return "icon_feedback"
        case .Settings:  return "icon_setting"
        case .RateUs:  return "icon_rateus"
        case .FollowUs:  return "icon_about"
        case .About:  return "icon_help"
        case .Blank: return nil
        }
    }
}

class MVProfielViewController: LXBaseTableViewController {
            
    fileprivate lazy var cellTypes: [CellType] = [.Feedback, .RateUs]
            
//#if DEBUG
//lazy var logViewHelper = LogViewHelper(logFilePath: FileManager.logFileURL?.path)
//#endif
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Account&Settings"
        
        self.tableView.backgroundColor = .backgroundColor
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.tableView.tableHeaderView = createTableHeaderView()
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 50))
        self.tableView.rowHeight = 89
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.tableView.separatorStyle = .none
//        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        self.tableView.reloadData()
        self.tableView.tableFooterView = createTableFooterView()
        
        #if DEBUG
        let leftButton = UIBarButtonItem(title: "WGlog", style: .plain) {
            self.presentLogView()
        }
        self.navigationItem.leftBarButtonItem = leftButton
        #endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.shadowColor = .clear
        appearance.backgroundColor = .clear
        appearance.backgroundImage = UIImage.init(color: .backgroundColor, size: CGSize(width: SCREEN_WIDTH, height: 100))
        appearance.shadowImage = UIImage()
        appearance.titleTextAttributes = [.foregroundColor: UIColor(hexString: "#FFFFFF")!, .font: UIFont.mediumMontserratFont(ofSize: 20)]

        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.backgroundColor = appearance.backgroundColor
        
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithDefaultBackground()
        tabAppearance.backgroundColor = .lightBackground
//        tabAppearance.shadowColor = .backgroundColor
        tabBarController?.tabBar.standardAppearance = tabAppearance
        tabBarController?.tabBar.scrollEdgeAppearance = tabAppearance
        
        if MVConfigModel.isVIP() {
            self.tableView.tableHeaderView = nil
            self.tableView.tableFooterView = createTableFooterView()
        } else {
            self.tableView.tableHeaderView = createTableHeaderView()
            self.tableView.tableFooterView = createTableFooterView()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if MVConfigModel.isVIP() {
            self.tableView.tableHeaderView = nil
            self.tableView.tableFooterView = createTableFooterView()
        } else {
            self.tableView.tableHeaderView = createTableHeaderView()
            self.tableView.tableFooterView = createTableFooterView()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}

extension MVProfielViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTypes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = .regularMontserratFont(ofSize: 16)
        let type = cellTypes[indexPath.row]
        switch type {
//        case .Version:
//            cell.detailTextLabel?.textColor = UIColor(hex: "C1C1C9")
//            cell.detailTextLabel?.font = .regularEczarFont(ofSize: 18)
//            cell.accessoryView = nil
//            cell.detailTextLabel?.text = AppInfo.version
        case .Blank:
            cell.accessoryView = nil
        default:
            if indexPath.row != cellTypes.count - 1 {
//                let line = UIImageView()
//                line.backgroundColor =  .init(hex: "#39425A")
//                cell.addSubview(line)
//                line.snp.makeConstraints { make in
//                    make.height.equalTo(0.5)
//                    make.left.equalTo(20)
//                    make.right.equalTo(-20)
//                    make.bottom.equalTo(0)
//                }
            }
//            cell.accessoryView = UIImageView(image: UIImage(named:"arrow_right_gray"))
        }
        if let image = UIImage(named: type.imageName ?? "") {
            cell.imageView?.image = image
            cell.imageView?.snp.makeConstraints { make in
                make.left.equalTo(16)
                make.width.height.equalTo(24)
                make.centerY.equalToSuperview()
            }
        }
        cell.textLabel?.text = type.title
        if let imageView = cell.imageView {
            cell.textLabel?.snp.makeConstraints { make in
                make.left.equalTo(imageView.snp.right).offset(16)
                make.height.equalTo(32)
                make.centerY.equalToSuperview()
                make.width.equalTo(200)
            }
        }
        
        let view = UIImageView(frame: cell.bounds)
        view.backgroundColor = .backgroundColor
        cell.selectedBackgroundView = view
        
        cell.backgroundColor = .backgroundColor
        cell.contentView.cornerRadius = 8
        cell.contentView.backgroundColor = .init(hex: "#192139")
        cell.contentView.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(0)
            make.bottom.equalTo(-16)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = cellTypes[indexPath.row]

        switch type {
        case .Feedback:
            let email = SUPPORT_EMAIL
            if let url = URL(string: "mailto:\(email)") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
        case .Settings: break
        case .RateUs:
            if let url = URL(string: "itms-apps://itunes.apple.com/app/itunes-u/id\(AppleAppID)?action=write-review&mt=8") {
                UIApplication.shared.open(url)
            }
        default: break
        }
        
        
//        switch type {
//        case .Account: GGAnalyticsManager.logEvent(FirebaseAnalyticsEvent0Name.act_me_click_account)
//        case .Feedback: GGAnalyticsManager.logEvent(FirebaseAnalyticsEvent0Name.act_me_click_feedback)
//        case .Settings: GGAnalyticsManager.logEvent(FirebaseAnalyticsEvent0Name.act_me_click_setting)
//        case .RateUs: GGAnalyticsManager.logEvent(FirebaseAnalyticsEvent0Name.act_me_click_rateus)
//        case .FollowUs: GGAnalyticsManager.logEvent(FirebaseAnalyticsEvent0Name.act_me_click_followus)
//        case .About: GGAnalyticsManager.logEvent(FirebaseAnalyticsEvent0Name.act_me_click_about)
//        case .Blank: break
//        }
    }
    
    
    func logoutAction() {
        
    }
    
    func presentLogView() {
//        #if DEBUG
//        self.logViewHelper?.fetchLogEntriesSinceLastFetch(completion: { logEntries in
//            debugPrint("logerVH.count = \(logEntries.count)")
//            for item in logEntries {
//                debugPrint("item = \(item.message)")
//            }
//        })
//        
//        let logVC = LogViewController()
//        navigationController?.pushViewController(logVC, animated: true)
//        #endif
    }
}


extension MVProfielViewController {
    func createTableHeaderView() -> UIView {

        let leftMargin = CGFloat(24)
        let view = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 148))
        
        let bgImageView = UIImageView(image: UIImage(named: "premium_bg"))
        bgImageView.contentMode = .scaleToFill
        bgImageView.width = SCREEN_WIDTH - 2*(leftMargin - 20)
        bgImageView.left = leftMargin - 20
        bgImageView.top = 16
        view.addSubview(bgImageView)

//        let shadowView = UIView(frame: CGRect(x: leftMargin + 19, y: 42, width: SCREEN_WIDTH - 2*(leftMargin + 19), height: 70))
//        shadowView.backgroundColor = .init(hex: "#0378FF")
//        view.addSubview(shadowView)
//        shadowView.layer.cornerRadius = 18
//        shadowView.layer.shadowOffset = CGSize(width: 0, height: 8)
//        shadowView.layer.shadowColor = UIColor(hex: "#0378FF").alpha(0.4).cgColor
//        shadowView.layer.shadowRadius = 11
//        shadowView.layer.shadowOpacity = 1
//        let shadowPath = UIBezierPath(roundedRect: shadowView.bounds, cornerRadius: 18)
//        shadowView.layer.shadowPath = shadowPath.cgPath
//        shadowView.isUserInteractionEnabled = false
//        view.addSubview(shadowView)
        
        let bgView = UIControl(frame: CGRect(x: leftMargin, y: 16, width: SCREEN_WIDTH - 2*leftMargin, height: 98))
        bgView.cornerRadius = 14
//        bgView.backgroundColor = .init(hex: "#0378FF")
        view.addSubview(bgView)
        
        let imageView = UIImageView(image: UIImage(named: "image_rocket"))
        imageView.left = 13
        imageView.top = 20 + 8
        bgView.addSubview(imageView)

        var label = UILabel()
        label.text = "Go Premium"
        label.font = .mediumMontserratFont(ofSize: 16)
        label.textAlignment = .left
        label.textColor = .white
        label.width = SCREEN_WIDTH - leftMargin*2
        label.height = 21
        label.left = 83
        label.top = 20 + 8
        bgView.addSubview(label)
        var previousView: UIView = label
        
        label = UILabel()
        label.text = "Unlock all features, remove ads, and use optimized and exclusive servers."
        label.font = .regularMontserratFont(ofSize: 12)
        label.numberOfLines = 2
        label.textAlignment = .left
        label.textColor = .white
        label.width = bgView.width - previousView.left - 20
        label.height = 34
        label.left = previousView.left
        label.bottom = bgView.height - 19 + 8
        bgView.addSubview(label)

        bgView.sb.addEventHandlerForControlEvents(.touchUpInside) { [unowned self] sender in
            self.showPremiumIfNeeded()
        }

//        view.height = previousView.bottom + 40
        return view
    }
    
    @discardableResult
    func showPremiumIfNeeded() -> Bool {
        guard MVConfigModel.isVIP() == false else { return true }
        
        let vc = MVPremiumViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        self.present(vc, animated: true)

        vc.complete = { [unowned vc] (result, errMsg) in
            vc.dismiss(animated: true) {
//                completion()
            }
        }
        
        return false
    }

    
    func createTableFooterView() -> UIView {
        self.tableView.tableFooterView = nil
//        var footerHeight = SCREEN_HEIGHT - NAVIGATIONBAR_HEIGHT - TABBAR_HEIGHT - (self.tableView.contentSize.height) - 20
        var footerHeight = self.view.height - (self.tableView.contentSize.height)

        if footerHeight < 90 {
            footerHeight = 90
        }
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: footerHeight))
        
        var label = termsLabel
        view.addSubview(label)
        label.left = 54
        label.bottom = footerHeight - 20
        var previousView: UIView = label

        label = ppLabel
        view.addSubview(label)
        label.right = SCREEN_WIDTH - 54
        label.bottom = previousView.bottom
        previousView = label
        
        let aHeight = previousView.top
        let space = (aHeight - 120)/2
        let imageView = UIImageView(image: UIImage(named: "logo_72"))
        imageView.top = space - 3
        imageView.centerX = SCREEN_WIDTH/2
        view.addSubview(imageView)
        previousView = imageView
        let control = UIControl(frame: imageView.frame)
        control.sb.addEventHandlerForControlEvents(.touchUpInside) { sender in
            UIPasteboard.general.string = AppInfo.shortDeviceId
        }
        view.addSubview(control)
        
        var uiLabel = UILabel()
        uiLabel.text = AppInfo.displayName
        uiLabel.font = .boldMontserratFont(ofSize: 16)
        uiLabel.textAlignment = .center
        uiLabel.textColor = .white
        uiLabel.width = SCREEN_WIDTH
        uiLabel.height = 19
        uiLabel.centerX = previousView.centerX
        uiLabel.top = previousView.bottom + 10
        view.addSubview(uiLabel)
        previousView = uiLabel

        uiLabel = UILabel()
        uiLabel.text = "Version " + AppInfo.version
        uiLabel.font = .regularMontserratFont(ofSize: 10)
        uiLabel.textAlignment = .center
        uiLabel.textColor = .init(hex: "#A3A6AF")
        uiLabel.width = SCREEN_WIDTH
        uiLabel.height = 13
        uiLabel.centerX = previousView.centerX
        uiLabel.top = previousView.bottom + 6
        view.addSubview(uiLabel)
        previousView = uiLabel

        return view
    }
    
     var termsLabel: ActiveLabel {
            let label = ActiveLabel()
         label.text = "Terms Of Use"
         let linkType = ActiveType.custom(pattern: label.text!)
            label.enabledTypes.append(linkType)
            label.customize { [unowned self] label in
                label.numberOfLines = 99
                label.lineSpacing = 3
                label.font = .regularMontserratFont(ofSize: 14)
                label.textAlignment = .left
                label.textColor = .init(hex: "#0378FF")
                label.customColor[linkType] = label.textColor

                label.configureLinkAttribute = { (type, attributes, isSelected) in
                    var atts = attributes

                    switch type {
                    case linkType:
                        atts[NSAttributedString.Key.underlineStyle] = 1
                    default: break
                    }

                    return atts
                }

                label.handleCustomTap(for: linkType) { [unowned self] str in
                    let vc = MVWebViewController()
                        vc.url = URL(string: TERMS_USE)
                    vc.navigationItem.title = "Terms Of Use"
                    vc.websiteTitleInNavigationBar = false
                    let nav = MVBaseNavigationController(rootViewController: vc)
                    nav.modalPresentationStyle = .fullScreen
                    self.present(nav, animated: true, completion: nil)
                }
            }
            label.width = SCREEN_WIDTH - 2*20
            label.sizeToFit()
            label.left = 54
        return label
    }

    var ppLabel: ActiveLabel {
           let label = ActiveLabel()
        label.text = "Privacy Policy"
        let linkType = ActiveType.custom(pattern: label.text!)
           label.enabledTypes.append(linkType)
           label.customize { [unowned self] label in
               label.numberOfLines = 99
               label.lineSpacing = 3
               label.font = .regularMontserratFont(ofSize: 14)
               label.textAlignment = .left
               label.textColor = .init(hex: "#0378FF")
               label.customColor[linkType] = label.textColor

               label.configureLinkAttribute = { (type, attributes, isSelected) in
                   var atts = attributes

                   switch type {
                   case linkType:
                       atts[NSAttributedString.Key.underlineStyle] = 1
                   default: break
                   }

                   return atts
               }

               label.handleCustomTap(for: linkType) { [unowned self] str in
                   let vc = MVWebViewController()
                    vc.url = URL(string: PRIVACY_POLICY)
                   vc.navigationItem.title = "Privacy Policy"
                   vc.websiteTitleInNavigationBar = false
                   let nav = MVBaseNavigationController(rootViewController: vc)
                   nav.modalPresentationStyle = .fullScreen
                   self.present(nav, animated: true, completion: nil)
               }
           }
           label.width = SCREEN_WIDTH - 2*20
           label.sizeToFit()
           label.left = 54
       return label
   }
}

