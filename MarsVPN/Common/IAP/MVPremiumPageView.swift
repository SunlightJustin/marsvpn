//
//  ViewController.swift
//  TYCyclePagerViewDemo_swift
//
//  Created by tany on 2017/7/20.
//  Copyright © 2017年 tany. All rights reserved.
//

import UIKit
import TYCyclePagerView

//fileprivate let pgHeigh = (228.0/314.0)*(SCREEN_WIDTH - 2*30) + 169
fileprivate let pgHeigh = CGFloat(438 - 44) + SAFE_AREA_TOP

class MVPremiumPageView: UIView {
        
    lazy var pagerView: TYCyclePagerView = {
        let pagerView = TYCyclePagerView(frame: self.bounds)
        pagerView.isInfiniteLoop = false
        return pagerView
    }()
    
    lazy var pageControl: TYPageControl = {
        let width = 8.0
        let pageControl = TYPageControl()
        pageControl.currentPageIndicatorTintColor =  .theme
        pageControl.pageIndicatorTintColor = UIColor(hexString: "#8E8E92")
        pageControl.pageIndicatorSize = CGSize(width: width, height: width)
        pageControl.currentPageIndicatorSize = CGSize(width: width, height: width)
                
//        let image = UIImage(color: UIColor(hex: "#FFFFFF").alpha(0.3), size: CGSize(width: 12*3, height: 12*3)).withRoundedCorners(radius: 6*3)
//        let currentImage = UIImage(color: .theme, size: CGSize(width: 20*3, height: 12*3)).withRoundedCorners(radius: 6*3)
        
//        pageControl.pageIndicatorSize = CGSize(width: 12, height: 12)
//        pageControl.currentPageIndicatorSize = CGSize(width: 20, height: 12)
//        pageControl.pageIndicatorImage = UIImage(named: "point_page_control_normal")
//        pageControl.currentPageIndicatorImage = UIImage(named: "point_page_control_current")
//        pageControl.indicatorImageContentMode = UIView.ContentMode.scaleToFill

        return pageControl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.height = pgHeigh
        
        self.pagerView.dataSource = self
        self.pagerView.delegate = self
        self.pagerView.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "cellId")
        self.addSubview(self.pagerView)
        
        self.pagerView.addSubview(self.pageControl)
        self.pageControl.frame = CGRect(x: 0, y: 0, width: self.pagerView.frame.width, height: 26)
        self.pageControl.centerY = self.pagerView.frame.height - 21 - 4
        
        self.pageControl.numberOfPages = 4
        self.pagerView.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MVPremiumPageView: TYCyclePagerViewDelegate, TYCyclePagerViewDataSource {
        
    func numberOfItems(in pageView: TYCyclePagerView) -> Int {
        return 4
    }
    
    func pagerView(_ pagerView: TYCyclePagerView, cellForItemAt index: Int) -> UICollectionViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cellId", for: index)
        cell.contentView.removeSubviews()
        
        switch index {
        case 0: cell.contentView.addSubview(MVPremiumPageView.pageView0())
        case 1: cell.contentView.addSubview(MVPremiumPageView.pageView1())
        case 2: cell.contentView.addSubview(MVPremiumPageView.pageView2())
        case 3: cell.contentView.addSubview(MVPremiumPageView.pageView3())
        default: break
        }
        return cell
    }
    
    func layout(for pageView: TYCyclePagerView) -> TYCyclePagerViewLayout {
        let layout = TYCyclePagerViewLayout()
        layout.itemSize = CGSize(width: pagerView.frame.width, height: pagerView.frame.height)
        layout.itemSpacing = 0
        layout.itemHorizontalCenter = true
        return layout
    }
    
    func pagerView(_ pageView: TYCyclePagerView, didScrollFrom fromIndex: Int, to toIndex: Int) {
        self.pageControl.currentPage = toIndex;
    }
}

extension MVPremiumPageView {
    
    static func pageView0() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: pgHeigh))
        let imageView = UIImageView(image: UIImage(named: "premium_0"))
        imageView.sizeToFit()
//        imageView.scale(to: SCREEN_WIDTH - 2*30)
        imageView.centerX = SCREEN_WIDTH/2
        imageView.centerY = 105 + 61 + (SAFE_AREA_TOP - 44)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        view.addSubview(imageView)
        
        var label = UILabel()
        label.text = "Up to premium"
        label.font = .boldMontserratFont(ofSize: 26)
        label.textAlignment = .center
        label.textColor = .white
        label.width = SCREEN_WIDTH
        label.height = 32
        label.top = 285 + (SAFE_AREA_TOP - 44)
        view.addSubview(label)
        let previouView: UIView = label
        
        label = UILabel()
        label.text = "Enjoy no ads, connect securely to 40+ locations"
        label.font = .regularMontserratFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 3
        label.textColor = UIColor(hex: "#DDDDDE")
        label.width = SCREEN_WIDTH - 2*32
        label.sizeToFit()
        label.top = previouView.bottom + 20
        label.centerX = SCREEN_WIDTH/2
        view.addSubview(label)
        return view
    }
    
    static func pageView1() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: pgHeigh))
        let imageView = UIImageView(image: UIImage(named: "premium_1"))
        imageView.sizeToFit()
        imageView.centerX = SCREEN_WIDTH/2
        imageView.centerY = 105 + 61 + (SAFE_AREA_TOP - 44)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        view.addSubview(imageView)
        
        var label = UILabel()
        label.text = "Ultra-fast streaming"
        label.font = .boldMontserratFont(ofSize: 26)
        label.textAlignment = .center
        label.textColor = .white
        label.width = SCREEN_WIDTH
        label.height = 32
        label.top = 285 + (SAFE_AREA_TOP - 44)
        view.addSubview(label)
        let previouView: UIView = label
        
        label = UILabel()
        label.text = "Start using mainstream streaming media smoothly"
        label.font = .regularMontserratFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 3
        label.textColor = UIColor(hex: "#DDDDDE")
        label.width = SCREEN_WIDTH - 2*32
        label.sizeToFit()
        label.top = previouView.bottom + 20
        label.centerX = SCREEN_WIDTH/2
        view.addSubview(label)
        return view
    }

    static func pageView2() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: pgHeigh))
        let imageView = UIImageView(image: UIImage(named: "premium_2"))
        imageView.sizeToFit()
        imageView.centerX = SCREEN_WIDTH/2
        imageView.centerY = 152 + (SAFE_AREA_TOP - 44)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        view.addSubview(imageView)
        
        var label = UILabel()
        label.text = "Servers world wide"
        label.font = .boldMontserratFont(ofSize: 26)
        label.textAlignment = .center
        label.textColor = .white
        label.width = SCREEN_WIDTH
        label.height = 32
        label.top = 285 + (SAFE_AREA_TOP - 44)
        view.addSubview(label)
        let previouView: UIView = label
        
        label = UILabel()
        label.text = "Use the most stable and speed premium server"
        label.font = .regularMontserratFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 3
        label.textColor = UIColor(hex: "#DDDDDE")
        label.width = SCREEN_WIDTH - 2*32
        label.sizeToFit()
        label.top = previouView.bottom + 20
        label.centerX = SCREEN_WIDTH/2
        view.addSubview(label)
        return view
    }
    
    
    static func pageView3() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: pgHeigh))
        let imageView = UIImageView(image: UIImage(named: "premium_3"))
        imageView.sizeToFit()
        imageView.centerX = SCREEN_WIDTH/2
        imageView.centerY = 183 + (SAFE_AREA_TOP - 44)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        view.addSubview(imageView)
        
        var label = UILabel()
        label.text = "Unlimited usage"
        label.font = .boldMontserratFont(ofSize: 26)
        label.textAlignment = .center
        label.textColor = .white
        label.width = SCREEN_WIDTH
        label.height = 32
        label.top = 285 + (SAFE_AREA_TOP - 44)
        view.addSubview(label)
        let previouView: UIView = label
        
        label = UILabel()
        label.text = "Unlimited bandwith and traffic while connected to any servers"
        label.font = .regularMontserratFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 3
        label.textColor = UIColor(hex: "#DDDDDE")
        label.width = SCREEN_WIDTH - 2*32
        label.sizeToFit()
        label.top = previouView.bottom + 20
        label.centerX = SCREEN_WIDTH/2
        view.addSubview(label)
        return view
    }


}
