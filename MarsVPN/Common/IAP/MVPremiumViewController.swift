//
//  MVPremiumGuideViewController.swift
//  Kinker
//
//  Created by clove on 8/5/20.
//  Copyright © 2020 personal.Justin. All rights reserved.
//

import Foundation
import ActiveLabel
import UIKit
import StoreKit


class MVPremiumViewController: LXBaseTableViewController {
    
    var complete: ((Bool, String?)->())?
    
    lazy var closeButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.setImage(UIImage(named: "button_close_normal")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.setImage(UIImage(named: "button_close")?.withRenderingMode(.alwaysOriginal), for: .highlighted)
        button.sizeToFit()
        let imageSize = button.size
        button.width = 44
        button.height = 44
        button.center.x = SCREEN_WIDTH - 20 - (imageSize.width)/2
        button.center.y = SAFE_AREA_TOP + 44/2
        button.sb.addEventHandlerForControlEvents(.touchUpInside) { [unowned self] sender in
            self.closeButtonAction()
        }
        return button
    }()
    
    lazy var termsLabel: ActiveLabel = {
            let label = ActiveLabel()
        
            var str = "By starting a 3-day free trial, you agree to the Terms Of Use and acknowledge the Privacy Policy. If you do not cancel your subscription at least 24 hours before the end of the 3-day free trial period, your monthly paid subscription will start and you will be charged $11.49 within 24 hours before the end of your trial. Upon purchasing a subscription, any unused portion of a free trial period will be forfeited. Your paid subscription will automatically renew and your Apple ID account will be charged $11.49 each month until you cancel it at least 24 hours before the end of the then-current subscription period. You can cancel your subscription at any time by following these instructions."

            let ppType = ActiveType.custom(pattern: "Terms Of Use")
            let termsType = ActiveType.custom(pattern: "Privacy Policy")
            label.enabledTypes.append(ppType)
            label.enabledTypes.append(termsType)
            label.customize { [unowned self] label in
                label.text = str
                label.numberOfLines = 99
                label.lineSpacing = 3
                label.font = .lightSystemFont(ofSize: 12)
                label.textAlignment = .left
                label.textColor = .init(hex: "#707070")
                label.customColor[ppType] = label.textColor
                label.customColor[termsType] = label.textColor

                label.configureLinkAttribute = { (type, attributes, isSelected) in
                    var atts = attributes

                    switch type {
                    case ppType, termsType:
                        atts[NSAttributedString.Key.underlineStyle] = 1
                    default: break
                    }

                    return atts
                }

                label.handleCustomTap(for: ppType) { [unowned self] str in
//                    let vc = MVWebViewController()
//                    vc.url = URL(string: PRIVACY_POLICY)
//                    vc.navigationItem.title = "Privacy Policy"
//                    vc.websiteTitleInNavigationBar = false
//                    let nav = MVBaseNavigationController(rootViewController: vc)
//                    nav.modalPresentationStyle = .fullScreen
//                    self.present(nav, animated: true, completion: nil)
                }

                label.handleCustomTap(for: termsType) { [unowned self] str in
//                    let vc = MVWebViewController()
//                        vc.url = URL(string: TERMS_USE)
//                    vc.navigationItem.title = "Terms Of Use"
//                    vc.websiteTitleInNavigationBar = false
//                    let nav = MVBaseNavigationController(rootViewController: vc)
//                    nav.modalPresentationStyle = .fullScreen
//                    self.present(nav, animated: true, completion: nil)
                }
            }
            label.width = SCREEN_WIDTH - 2*16
            label.sizeToFit()
            label.left = 20
        return label
    }()
    
    override func viewDidLoad() {
          super.viewDidLoad()
        
        let imageView = UIImageView(image: UIImage(named: "lauch_bg"))
        self.tableView.backgroundView = imageView
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.tableView.tableHeaderView = createTableHeaderView()
//        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: IS_IPHONEX ? 0 : 20))

        if MVIAPManager.shared.products1?.count ?? 0 > 0 {
            updatePrice()
        } else {
            MVIAPManager.fetchProduct1 { result in
                if result {
                    self.tableView.tableHeaderView = self.createTableHeaderView()
                    self.updatePrice()
                }
            }
        }
        
        AnalyticsManager.logEvent("premium_show")
    }
      
      override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          self.navigationController?.setNavigationBarHidden(true, animated: false)
          GGAnalyticsManager.cache("prmium", with: .payment_open_from)
      }
      
      override func viewWillDisappear(_ animated: Bool) {
          super.viewWillDisappear(animated)
      }
    
    func closeButtonAction() {
        self.pushNext()
    }
    
    lazy var restoreButton: UIButton = {
        let button = UIButton()
        button.setTitle("Restore", for: .normal)
        button.titleLabel?.font = .boldMontserratFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.sizeToFit()
        button.height = 44
        button.centerX = SCREEN_WIDTH/2
        button.sb.addEventHandlerForControlEvents(.touchUpInside) { [unowned self] (btn) in
            self.restoreTapped()
        }

        return button
    }()
    
    func restoreTapped() {
        GGAnalyticsManager.logEvent(FirebaseAnalyticsEvent0Name.act_restore)

        HUD.startLoading()
        MVIAPManager.restore(completion: { (result, errMsg, date) in
            if result {
                HUD.flash("Restore Finished")
                if MVConfigModel.isVIP() {
                    self.pushNext()
                }
            } else {
                if let str = errMsg {
                    HUD.flash(str)
                } else {
                    HUD.hide(afterDelay: 1)
                }
            }
            self.complete?(result, errMsg)
        })
    }

    var controls = [MVPremiumControl]()
    func createTableHeaderView() -> UIView {
        
        self.tableView.tableHeaderView?.removeSubviews()
        self.controls = [MVPremiumControl]();

        let leftMargin = CGFloat(28)
        let view = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 100))
        view.addSubview(closeButton)

        var label = UILabel()
        label.text = "Upgrade to"
        label.font = .boldSystemFont(ofSize: 24)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.textColor = .white
        label.sizeToFit()
        label.height = 29
        label.top = 83 + (SAFE_AREA_TOP - 44)
        label.left = (SCREEN_WIDTH - (label.width + 4 + 96))/2
        view.addSubview(label)
        var previousView: UIView = label
        
        let button = UIButton(type: .custom)
        button.isEnabled = false
        button.setTitle("Premium", for: .disabled)
        button.setImage(UIImage(named: "vip_icon_18"), for: .disabled)
        button.titleLabel?.font = .boldMontserratFont(ofSize: 12)
        button.layoutButtonImage(space: 2)
        button.width = 96
        button.height = 29
        button.backgroundColor = .theme
        button.cornerRadius = 14
        button.clipsToBounds = true
        button.centerY = previousView.centerY
        button.right = SCREEN_WIDTH - previousView.left
        view.addSubview(button)

        label = UILabel()
        label.text = "Get fast and unlimited servers"
        label.font = .regularMontserratFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.textColor = .white
        label.width = SCREEN_WIDTH - leftMargin*2
        label.height = 18
        label.centerX = SCREEN_WIDTH/2
        label.top = previousView.bottom + 16
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalTo(leftMargin)
            make.right.equalTo(-leftMargin)
            make.height.equalTo(18)
            make.top.equalTo(previousView.bottom + 16)
        }
        previousView = label

        
        let stringArray = [
                           "Ultra fast optimize servers",
                           "500+ servers",
                           "Unlimited bandwidth and traffic",
                           "Ad-free",
                           "Streaming for Netflix, HBO and more",
        ]
        for (index, item) in stringArray.enumerated() {
            let imageView = UIImageView(image: UIImage(named: "green_icon_\(index)"))
            imageView.contentMode = .center
            view.addSubview(imageView)
            if index == 0 {
                imageView.snp.makeConstraints { make in
                    make.size.equalTo(CGSize(width: 28, height: 28))
                    make.left.equalTo(55)
                    make.top.equalTo(previousView.snp.bottom).offset(32)
                }
            } else {
                imageView.snp.makeConstraints { make in
                    make.size.equalTo(CGSize(width: 28, height: 28))
                    make.left.equalTo(55)
                    make.top.equalTo(previousView.snp.bottom).offset(20)
                }
            }
            
            label = UILabel()
            label.font = .regularMontserratFont(ofSize: 14)
            label.textAlignment = .left
            label.text = item
            label.numberOfLines = 2
            label.textColor = .white
            view.addSubview(label)
            label.snp.makeConstraints { make in
                make.left.equalTo(imageView.snp.right).offset(8)
                make.right.equalTo(-50)
                make.centerY.equalTo(imageView.snp.centerY)
            }
            previousView = label
            
            if index == 4 {
                previousView = imageView
            }
        }

        if let products = MVIAPManager.shared.products1 {
            for (index, product) in  products.enumerated() {
                let control = MVPremiumControl(best: index == 1)
                view.addSubview(control)
                
                if (index == 0) {
                    control.snp.makeConstraints { make in
                        make.size.equalTo(control.size)
                        make.left.equalTo(24)
                        make.top.equalTo(previousView.snp.bottom).offset(31)
                    }
                } else if (index == products.count - 1) {
                    control.snp.makeConstraints { make in
                        make.size.equalTo(control.size)
                        make.left.equalTo(24)
                        make.top.equalTo(previousView.snp.bottom).offset(30)
//                        make.bottom.lessThanOrEqualTo(0)
                    }
                } else {
                    control.snp.makeConstraints { make in
                        make.size.equalTo(control.size)
                        make.left.equalTo(24)
                        make.top.equalTo(previousView.snp.bottom).offset(30)
                    }
                }
                
                control.update(index: index, product: product)
                previousView = control
                
                control.isSelected = true
                controls.append(control)
                control.sb.addEventHandlerForControlEvents(.touchUpInside) { [unowned self] sender in
                    self.controlsTapped(index)
                }
            }
        }
        
        
        view.addSubview(restoreButton)
        restoreButton.snp.makeConstraints { make in
            make.size.equalTo(self.restoreButton.size)
            make.centerX.equalToSuperview()
            make.top.equalTo(previousView.snp.bottom).offset(16)
            make.bottom.lessThanOrEqualTo(0)
        }
        previousView = restoreButton

        
        let viewHeight = SCREEN_HEIGHT
        let size = view.systemLayoutSizeFitting(CGSize(width: SCREEN_WIDTH, height: 100), withHorizontalFittingPriority: .sceneSizeStayPut, verticalFittingPriority: .dragThatCanResizeScene)
    
        termsLabel.width = SCREEN_WIDTH - 2*leftMargin
        termsLabel.sizeToFit()
        termsLabel.left = leftMargin
        termsLabel.top = size.height - 5
        view.addSubview(termsLabel)
        previousView = termsLabel
        view.height = previousView.bottom

//        let viewHeight = SCREEN_HEIGHT - NAVIGATIONBAR_HEIGHT
//        if viewHeight > termsLabel.bottom {
//            view.height = viewHeight
//            termsLabel.bottom = viewHeight - IPHONEX_BOTTOM
//        } else {
//            view.height = previousView.bottom
//        }

        
        
//
//        view.height = size.height
//
//
//        label = termsLabel
//        view.addSubview(label)
//        label.snp.makeConstraints { make in
//            make.left.equalTo(leftMargin)
//            make.right.equalTo(-leftMargin)
//            make.top.greaterThanOrEqualTo(previousView.snp.bottom).offset(24)
//            make.bottom.equalTo(-(10 + IPHONEX_BOTTOM))
//        }
//
////        view.height = viewHeight
//
//        let size = view.systemLayoutSizeFitting(CGSize(width: SCREEN_WIDTH, height: viewHeight), withHorizontalFittingPriority: .sceneSizeStayPut, verticalFittingPriority: .dragThatCanResizeScene)
//
//        view.height = size.height
//
////
////        if viewHeight > termsLabel.bottom {
////            termsLabel.bottom = viewHeight - IPHONEX_BOTTOM - 30
////            view.height = viewHeight
////        } else {
////            view.height = previousView.bottom
////        }

        return view
    }
    
    func updatePrice() {
        if let products = MVIAPManager.shared.products1, products.count > 1 {
            let product = products[1]
            let price = product.price.floatValue

            var dayCount = 0
            if let subs = product.introductoryPrice {
                  let unit = subs.subscriptionPeriod.unit
                  let number = subs.subscriptionPeriod.numberOfUnits
                    switch unit {
                    case .day:
                        dayCount = number
                    case .week:
                        dayCount = number*7
                    case .month:
                        dayCount = number*30
                    case .year:
                        dayCount = number*365
                    @unknown default:
                        break
                    }
            }


            var priceStr = ""
            priceStr = String(format: "%.2f", price)
            priceStr = priceStr.replacingOccurrences(of: ".00", with: "")
            guard let m = product.priceLocale.currencySymbol else { return }
            let currencyStr = String(m)
            let currencyPriceStr = String(format: "%@%.2f", currencyStr, price)

            var str = "By starting a %d-day free trial, you agree to the Terms Of Use and acknowledge the Privacy Policy. If you do not cancel your subscription at least 24 hours before the end of the %d-day free trial period, your monthly paid subscription will start and you will be charged %@ within 24 hours before the end of your trial. Upon purchasing a subscription, any unused portion of a free trial period will be forfeited. Your paid subscription will automatically renew and your Apple ID account will be charged %@ each month until you cancel it at least 24 hours before the end of the then-current subscription period. You can cancel your subscription at any time by following these instructions."
            if dayCount > 0 {
                str = String(format: str, dayCount, dayCount, currencyPriceStr, currencyPriceStr)
            } else {
                str = String(format: str, 0, 0, currencyPriceStr, currencyPriceStr)
            }

            termsLabel.text = str
            termsLabel.sizeToFit()
            self.tableView.tableHeaderView?.height = termsLabel.bottom + 34
        }
    }
    
    func controlsTapped(_ index: Int) {
//        guard index < self.controls.count else { return }
//        for item in controls {
//            item.isSelected = false
//        }
        
//        controls[index].isSelected = true
        productTapped(index)
    }
    
    func pushNext() {
        self.dismiss(animated: true)
    }
    
    func productTapped(_ index: Int) {
        guard index < MVIAPManager.shared.productIdentifiers1.count else { return }
        let productIdentifier = MVIAPManager.shared.productIdentifiers1[index]


        HUD.startLoading()
        MVIAPManager.purchase(productIdentify: productIdentifier) { (result, errMsg, date) in
            if result {
                HUD.flash("Purchase Successfully")

                if index == 0 {
                    GGAnalyticsManager.logEvent(event0: FirebaseAnalyticsEvent0Name.act_purchase_result_1month_success, event1: .payment_open_from)
                } else {
                    GGAnalyticsManager.logEvent(event0: FirebaseAnalyticsEvent0Name.act_purchase_result_1year_success, event1: .payment_open_from)
                }
                self.pushNext()
            } else {
                if let str = errMsg {
                    if str == payment_sheet_cancelled {
                        HUD.hide()

                        if index == 0 {
                            GGAnalyticsManager.logEvent(event0: FirebaseAnalyticsEvent0Name.act_purchase_result_1month_canceled, event1: .payment_open_from)
                        } else {
                            GGAnalyticsManager.logEvent(event0: FirebaseAnalyticsEvent0Name.act_purchase_result_1year_canceled, event1: .payment_open_from)
                        }
                    } else {
                        let text = str.count > 0 ? str : "Unkonwned2 error"
                        HUD.flash(text)
                        if index == 0 {
                            GGAnalyticsManager.logEvent(event0: FirebaseAnalyticsEvent0Name.act_purchase_result_1month_failed, event1: .payment_open_from)
                        } else {
                            GGAnalyticsManager.logEvent(event0: FirebaseAnalyticsEvent0Name.act_purchase_result_1year_failed, event1: .payment_open_from)
                        }
                    }
                } else {
                    HUD.flash("Unkonwned1 error")
                }
            }
            debugPrint("MVIAPManager.shared.purchase result = \(result), err = \(errMsg)")
            self.complete?(result, errMsg)
        }
    }
    
   
}
