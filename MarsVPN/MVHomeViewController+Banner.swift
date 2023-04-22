//
//  MVHomeViewController.swift
//  MarsVPN
//
//  Created by Justin on 2022/12/7.
//

import Foundation

extension MVHomeViewController {
    func createBannerView() -> UIControl {
        let view = UIControl(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 216))
        view.clipsToBounds = false
        view.top = SCREEN_HEIGHT - TABBAR_HEIGHT - NAVIGATIONBAR_HEIGHT
//        view.bottom = SCREEN_HEIGHT - TABBAR_HEIGHT - NAVIGATIONBAR_HEIGHT

        let bg = UIImageView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 216 + 190))
        bg.backgroundColor = .init(hex: "#192139")
        bg.cornerRadius = 35
        bg.clipsToBounds = true
        view.addSubview(bg)
        
        let bgLayer = CAGradientLayer()
        bgLayer.frame = bg.bounds
        bgLayer.colors = [UIColor.init(hex: "#192139").alpha(0.9).cgColor, UIColor.init(hex: "#192139").cgColor]
        bgLayer.startPoint = CGPoint(x: 0.5, y: 0)
        bgLayer.endPoint = CGPoint(x: 0.5, y: 1)
        bg.layer.addSublayer(bgLayer)
        
//        let indicate = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 4))
//        indicate.backgroundColor = .init(hex: "#282E3F")
//        indicate.cornerRadius = 2
//        view.addSubview(indicate)
//        indicate.centerX = view.width/2
//        indicate.top = 8
                
        var label = UILabel()
        label.text = "How do you rate our services?"
        label.font = .boldMontserratFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.textColor = .white
        label.width = SCREEN_WIDTH
        label.height = 19
        label.centerX = SCREEN_WIDTH/2
        label.top = 50
        view.addSubview(label)
        var previousView: UIView = label
        
        label = UILabel()
        label.text = "Rating us"
        label.font = .regularMontserratFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.textColor = .white
        label.width = SCREEN_WIDTH
        label.height = 18
        label.centerX = SCREEN_WIDTH/2
        label.top = previousView.bottom + 30
        view.addSubview(label)
        previousView = label
        
        let starView = RatingView(frame: CGRect(x: 0, y: 0, width: 250, height: 50))
        starView.starCount = 5
        starView.centerX = SCREEN_WIDTH/2
        starView.centerY = previousView.bottom + 44
        view.addSubview(starView)
        starView.editable = true
        starView.halfStarsAllowed = false
        starView.delegate = self
        ratingView = starView
        
        let button = UIButton(type: .roundedRect)
        button.setImage(UIImage(named: "button_close")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.sizeToFit()
        let imageSize = button.size
        button.width = 44
        button.height = 44
        button.center.x = SCREEN_WIDTH - 20 - (imageSize.width)/2
        button.center.y = 20 + 44/2
        view.addSubview(button)
        button.sb.addEventHandlerForControlEvents(.touchUpInside) { [unowned self] sender in
            self.hide()
        }
        
        
        return view
    }
    
    func showStarViewIfNeeded() {
        MVConfigModel.isShownRateUsCountdown -= 1
        guard MVConfigModel.shouldShownRateUs else { return }
        show()
    }
    
    func show() {
        MVConfigModel.isShownRateUs = true

        ratingView?.delegate = nil
        ratingView?.rating = 0
        ratingView?.delegate = self
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            self.starView?.bottom = SCREEN_HEIGHT - TABBAR_HEIGHT - NAVIGATIONBAR_HEIGHT
        }
        
        let tabAppearance = UITabBarAppearance()
        tabAppearance.backgroundImage = UIImage()
        tabAppearance.shadowImage = UIImage()
        tabAppearance.configureWithTransparentBackground()
        tabBarController?.tabBar.standardAppearance = tabAppearance
        tabBarController?.tabBar.scrollEdgeAppearance = tabAppearance
    }
    
    func hide() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            self.starView?.top = SCREEN_HEIGHT - TABBAR_HEIGHT - NAVIGATIONBAR_HEIGHT
            
            let tabAppearance = UITabBarAppearance()
            tabAppearance.configureWithDefaultBackground()
            tabAppearance.backgroundColor = .lightBackground
            tabAppearance.shadowImage = nil
            self.tabBarController?.tabBar.standardAppearance = tabAppearance
            self.tabBarController?.tabBar.scrollEdgeAppearance = tabAppearance
        }
    }
    
    func ratingAction(rate: Int) {

        if rate >= 4 {
            if let url = URL(string: "itms-apps://itunes.apple.com/app/itunes-u/id\(AppleAppID)?action=write-review&mt=8") {
                startTime = Date()
                UIApplication.shared.open(url)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.hide()
//                self.complete?(true, nil)
            }
        }
    }
}

extension MVHomeViewController: RatingViewDelegate {
    func ratingView(_ ratingView: RatingView, didChangeRating newRating: Float) {
        let f = Int(newRating)
        let dd = Int(ceil(newRating))
        if f < dd {
            ratingView.rating = Float(dd)
        }
        
//        FirebaseAnalyticsEvent0Name.act_star_1
        let eventName = "act_star_\(dd)"
        GGAnalyticsManager.logEvent(event0: eventName)
        
        ratingAction(rate: dd)

//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
//            self.complete?(true, nil)
//        }
        debugPrint("ratingView \(ratingView) didChangeRating \(newRating), ceil = \(dd), f=\(f), dd = \(dd)")
    }
}

