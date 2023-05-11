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


fileprivate let pgHeigh = (228.0/314.0)*(SCREEN_WIDTH - 2*30) + 169

class MVPremiumGuideViewController: LXBaseTableViewController {
    deinit {
        debugPrint("\(NSStringFromClass(type(of: self))) \(#function)")
    }

    var complete: ((Bool, String?)->())?

    lazy var continueButton: UIButton = {
        let button = UIButton.createConsistent("Continue")
        button.sb.addEventHandlerForControlEvents(.touchUpInside) { [unowned self] sender in
            self.continueTapped()
        }
        return button
    }()
    
    lazy var restoreLabel: ActiveLabel = {
           let label = ActiveLabel()
        label.text = "Restore purchase"
        let linkType = ActiveType.custom(pattern: label.text!)
           label.enabledTypes.append(linkType)
           label.customize { [unowned self] label in
               label.numberOfLines = 99
               label.lineSpacing = 5
               label.font = .regularMontserratFont(ofSize: 14)
               label.textAlignment = .left
               label.textColor = .white
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
                   self.restoreTapped()
               }
           }
           label.width = SCREEN_WIDTH - 2*20
           label.sizeToFit()
//           label.left = 54
       return label
   }()

    lazy var termsLabel: ActiveLabel = {
            let label = ActiveLabel()
        
            var str = "By starting a 3-day free trial, you agree to the Terms Of Use and acknowledge the Privacy Policy. If you do not cancel your subscription at least 24 hours before the end of the 7-day free trial period, your monthly paid subscription will start and you will be charged $11.49 within 24 hours before the end of your trial. Upon purchasing a subscription, any unused portion of a free trial period will be forfeited. Your paid subscription will automatically renew and your Apple ID account will be charged $11.49 each month until you cancel it at least 24 hours before the end of the then-current subscription period. You can cancel your subscription at any time by following these instructions."

            let termsType = ActiveType.custom(pattern: "Terms Of Use")
            let ppType = ActiveType.custom(pattern: "Privacy Policy")
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
                    let vc = MVWebViewController()
                     vc.url = URL(string: PRIVACY_POLICY)
                    vc.navigationItem.title = "Privacy Policy"
                    vc.websiteTitleInNavigationBar = false
                    let nav = MVBaseNavigationController(rootViewController: vc)
                    nav.modalPresentationStyle = .fullScreen
                    self.present(nav, animated: true, completion: nil)
                }

                label.handleCustomTap(for: termsType) { [unowned self] str in
                    let vc = MVWebViewController()
                    vc.url = URL(string: TERMS_USE)
                    vc.navigationItem.title = "Terms Of Use"
                    vc.websiteTitleInNavigationBar = false
                    let nav = MVBaseNavigationController(rootViewController: vc)
                    nav.modalPresentationStyle = .fullScreen
                    self.present(nav, animated: true, completion: nil)
                }
            }
            label.width = SCREEN_WIDTH - 2*16
            label.sizeToFit()
            label.left = 20
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        #if DEBUG
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            self.pushNext()
//        }
//        #endif

        self.tableView.contentInsetAdjustmentBehavior = .never
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.backgroundColor = .backgroundColor
        self.tableView.tableHeaderView = createTableHeaderView()
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1))

        self.navigationController?.viewControllers.removeFirst()

        if MVIAPManager.shared.products1?.count ?? 0 > 0 {
            updatePrice()
        } else {
            MVIAPManager.fetchProduct1 { result in
                if result {
                    self.updatePrice()
                }
            }
        }
        
        AnalyticsManager.logEvent("premium_guide_show")
    }

      override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          self.navigationController?.setNavigationBarHidden(true, animated: false)
//          DispatchQueue.once {
//              self.tableView.setContentOffset(.zero, animated: false)
//          }

          GGAnalyticsManager.cache("from_guide", with: .payment_open_from)
      }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

      override func viewWillDisappear(_ animated: Bool) {
          super.viewWillDisappear(animated)
      }

    func updatePrice() {
        if let products = MVIAPManager.shared.products1, products.count > selectIndex {
            let product = products[selectIndex]
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

    lazy var closeButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.setImage(UIImage(named: "button_close")?.withRenderingMode(.alwaysOriginal), for: .normal)
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
 

    func closeButtonAction() {
        MVConfigModel.isShownPurchaseGuideToday = true
        pushNext()
    }
    
    var controls = [MVPremiumControl]()
    private var vipPageView: MVPremiumPageView!
    func createTableHeaderView() -> UIView {

        let view = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 100))
        let pageView = MVPremiumPageView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: pgHeigh))
        view.addSubview(pageView)
        vipPageView = pageView

//        if User.current?.groupABTest == .B {
        view.addSubview(closeButton)
//        }
        var previousView: UIView = pageView
        
        if let products = MVIAPManager.shared.products1 {
            for (index, product) in  products.enumerated() {
                let control = MVPremiumControl(best: index == 1)
                view.addSubview(control)
                control.left = 24
                
                if (index == 0) {
                    control.top = previousView.bottom  + 0
                } else if (index == products.count - 1) {
                    control.top = previousView.bottom + 26
                } else {
                    control.top = previousView.bottom + 26
                }
                
                control.update(index: index, product: product)
                previousView = control
                
                control.isSelected = index == 1
                controls.append(control)
                control.sb.addEventHandlerForControlEvents(.touchUpInside) { [unowned self] sender in
                    self.controlsTapped(index)
                }
            }
        }


        view.addSubview(continueButton)
        continueButton.top = previousView.bottom + 32
        continueButton.centerX = SCREEN_WIDTH/2
        previousView = continueButton

        view.addSubview(restoreLabel)
        restoreLabel.centerX = SCREEN_WIDTH/2
        restoreLabel.centerY = previousView.bottom + 16 + 9
        previousView = restoreLabel

        view.addSubview(termsLabel)
        termsLabel.top = previousView.bottom + 18
        previousView = termsLabel

        view.height = previousView.bottom + 33
        return view
    }
    
    var selectIndex = 1
    func controlsTapped(_ index: Int) {
        selectIndex = index
        for item in controls {
            item.isSelected = false
        }
        controls[index].isSelected = true
        
        updatePrice()
    }

    func productTapped(_ index: Int) {
        guard index < MVIAPManager.shared.productIdentifiers1.count else { return }
        let productIdentifier = MVIAPManager.shared.productIdentifiers1[index]

        HUD.startLoading()
        MVIAPManager.purchase(productIdentify: productIdentifier) { (result, error, date) in
            if result {
                HUD.flash("Purchase Successfully")

                if index == 0 {
                    GGAnalyticsManager.logEvent(event0: FirebaseAnalyticsEvent0Name.act_purchase_result_1month_success, event1: .payment_open_from)
                } else {
                    GGAnalyticsManager.logEvent(event0: FirebaseAnalyticsEvent0Name.act_purchase_result_1year_success, event1: .payment_open_from)
                }
                
                GGAnalyticsManager.logEvent(FirebaseAnalyticsEvent0Name.act_purchase_success)
                self.pushNext()
            } else {
                if let error = error {
                    // don't show error message
                    if .paymentCancelled == error.code {
                        HUD.hide()

                        if index == 0 {
                            GGAnalyticsManager.logEvent(event0: FirebaseAnalyticsEvent0Name.act_purchase_result_1month_canceled, event1: .payment_open_from)
                        } else {
                            GGAnalyticsManager.logEvent(event0: FirebaseAnalyticsEvent0Name.act_purchase_result_1year_canceled, event1: .payment_open_from)
                        }
                    } else {
                        let text = error.localizedMessage.count > 0 ? error.localizedMessage : "Unkonwned2 error"
                        HUD.flash(text)
                        if index == 0 {
                            GGAnalyticsManager.logEvent(event0: FirebaseAnalyticsEvent0Name.act_purchase_result_1month_failed, event1: .payment_open_from)
                        } else {
                            GGAnalyticsManager.logEvent(event0: FirebaseAnalyticsEvent0Name.act_purchase_result_1year_failed, event1: .payment_open_from)
                        }
                        
                        GGAnalyticsManager.logEvent(FirebaseAnalyticsEvent0Name.act_purchase_failed, event1: error.code.rawValue.string )
                    }
                } else {
                    HUD.flash("Unkonwned1 error")
                }
            }
            debugPrint("MVIAPManager.shared.purchase result = \(result), err = \(error?.localizedMessage)")
            self.complete?(result, error?.localizedMessage)
        }
    }
    
    func continueTapped() {
        productTapped(selectIndex)
    }

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

    func pushNext() {
        MVMainViewController.loginTransition()
    }
}






class MVPremiumControl: UIControl {
    
    var subtitleLabel: UILabel!
    var bgImageView: UIImageView!
    var isBest = false;
    
    init(best: Bool=false) {
        super.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH - 2*24, height: 70))
        isBest = best
        
        let view = self
        view.height = height
        view.width = width
        view.clipsToBounds = false

        let bgView = UIImageView(frame: view.bounds)
        bgView.backgroundColor = .init(hex: "#192139")
        bgView.layer.cornerRadius = 16
        bgView.clipsToBounds = true
        bgView.borderWidth = 1
        bgView.borderColor = .init(hex: "#FFE6AB")
        view.addSubview(bgView)
        bgImageView = bgView
        
        var label = titleLabel
        label.top = 17
        label.left = 24
        view.addSubview(label)
        titleLabel = label
        var previousView: UIView = label

        label = priceLabel
        label.left = previousView.left
        label.bottom = height - 17
        view.addSubview(label)
        previousView = label
        
        label = UILabel()
        label.font = .boldMontserratFont(ofSize: 18)
        label.textAlignment = .right
        label.numberOfLines = 1
        label.textColor = .init(hex: "#FFE6AB")
        label.height = 22
        label.width = view.width
        label.right = view.width - 29
        label.centerY = self.height/2
        view.addSubview(label)
        subtitleLabel = label
        
        view.addSubview(saveLabel)
        saveLabel.centerX = width/2
        saveLabel.centerY = 0
        
//        view.addSubview(freeLabel)
//        freeLabel.centerY = titleLabel.centerY
    }
    
    lazy var titleLabel: UILabel = {
        var label = UILabel()
        label.text = "$"
        label.font = .boldSystemFont(ofSize: 14)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.textColor = .white
        label.sizeToFit()
        label.width = 200
        return label
    }()

    lazy var priceLabel: UILabel = {
        var label = UILabel()
        label.text = "$"
        label.font = .boldSystemFont(ofSize: 14)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.textColor = .white
        label.sizeToFit()
        label.width = 200
        return label
    }()
    
    lazy var saveLabel: UILabel = {
        var label = UILabel()
        label.font = .boldMontserratFont(ofSize: 12)
        label.text = "Limited offer Save 60%"
        label.textAlignment = .center
        label.numberOfLines = 1
        label.height = 20
        label.width = 166
        label.textColor = .init(hex: "#755200")
        label.cornerRadius = 8
        label.backgroundColor = .init(hex: "#FFE6AB")
        return label
    }()

    lazy var freeLabel: UILabel = {
        var label = UILabel()
        label.font = .mediumSystemFont(ofSize: 10)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.textColor = .init(hex: "#0D2940")
        return label
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                bgImageView.borderWidth = 1
                bgImageView.borderColor = .init(hex: "#FFE6AB")
            } else {
                bgImageView.borderWidth = 0
                bgImageView.borderColor = .init(hex: "#FFE6AB")
            }
        }
    }
    
    func update(index: Int, product: SKProduct) {
        let price = product.price.floatValue

        let currencyStr = product.priceLocale.currencySymbol ?? "$"
        var priceStr = String(format: "%.2f", price)
        priceStr = priceStr.replacingOccurrences(of: ".00", with: "")
        let currencyPriceStr = String(format: "%@%@", currencyStr, priceStr)
//        var currencyPricePer = ""
        var title = ""
        var perString = ""
        var freeDaysString = ""

        var freeDayCount = 0
        if let subs = product.introductoryPrice {
              let unit = subs.subscriptionPeriod.unit
              let number = subs.subscriptionPeriod.numberOfUnits
                switch unit {
                case .day:
                    freeDayCount = number
                case .week:
                    freeDayCount = number*7
                case .month:
                    freeDayCount = number*30
                case .year:
                    freeDayCount = number*365
                @unknown default:
                    break
                }
        }
        
        let number = product.subscriptionPeriod?.numberOfUnits ?? 0
        let subscriptionPeriod = product.subscriptionPeriod?.unit ?? .day
        var basicDayCount = 0
        switch subscriptionPeriod {
        case .day: basicDayCount = number
        case .week: basicDayCount = number*7
        case .month: basicDayCount = number*30
        case .year: basicDayCount = number*365
        @unknown default:
            break
        }
        
        if freeDayCount > 0 {
            freeDaysString = "\(freeDayCount)-DAY TRAIL"
        }
        if basicDayCount >= 364 {
            title = "1 Year"
            perString = "\(currencyStr)\(priceStr)/Year"
        } else if basicDayCount >= 30 {
            title = "1 Month"
            perString = "\(currencyStr)\(priceStr)/Month"
        } else if basicDayCount >= 7 {
            title = "1 Week"
            perString = "\(currencyStr)\(priceStr)/Week"
        } else {
            
        }
        
        saveLabel.isHidden = !isBest
        titleLabel.text = title
        priceLabel.text = freeDaysString
        subtitleLabel.text = perString
        
        
        if freeDayCount > 0 {
            priceLabel.isHidden = false
            priceLabel.text = freeDaysString
            
            titleLabel.top = 17
            priceLabel.bottom = self.height - 17
        } else {
            priceLabel.isHidden = true
            titleLabel.centerY = self.height/2
        }
    }
}
