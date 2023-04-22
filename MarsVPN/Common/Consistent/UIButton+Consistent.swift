//
//  UIButton+Consistent.swift
//  Kinker
//
//  Created by clove on 7/27/20.
//  Copyright © 2020 personal.Justin. All rights reserved.
//

import Foundation


extension UIButton {
    
    
    class func createConsistent(_ title: String,
                                width: CGFloat=UIScreen.main.bounds.size.width-24*2,
                                height: CGFloat=48,
                                font: UIFont = .boldMontserratFont(ofSize: 16),
                                textColor: UIColor?=UIColor.white) -> UIButton {
        let button = UIButton(type: .roundedRect)
        button.width = width
        button.height = height
        button.contentMode = .center
        button.setTitleColor(.textColor, for: .normal)
        button.titleLabel?.numberOfLines = 1
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = font
        button.cornerRadius = 14
        button.layer.masksToBounds = true
        button.backgroundColor = .theme
        button.setTitle(title, for: .normal)
        
        if let color = textColor {
            button.setTitleColor(color, for: .normal)
        }
        
        return button
    }
    
    
    
    
    
}


enum ButtonImageStyle {
    case top /// image在上，label在下
    case left /// image在左，label在右
    case bottom /// image在下，label在上
    case right /// image在右，label在左
}
extension UIButton {
    func layoutButtonImage(style:ButtonImageStyle=ButtonImageStyle.left,space:CGFloat = 5){
        
        let imageWith = self.imageView?.bounds.width ?? 0
        let imageHeight = self.imageView?.bounds.height ?? 0
        
        let labelWidth = self.titleLabel?.intrinsicContentSize.width ?? 0
        let labelHeight = self.titleLabel?.intrinsicContentSize.height ?? 0
        
        var imageEdgeInsets = UIEdgeInsets.zero
        var labelEdgeInsets = UIEdgeInsets.zero
        var contentEdgeInsets = UIEdgeInsets.zero
        
        let bWidth = self.bounds.width
        
        let min_height = min(imageHeight, labelHeight)
        
        switch style {
        case .left:
            self.contentVerticalAlignment = .center
            imageEdgeInsets = UIEdgeInsets(top: 0,
                                           left: 0,
                                           bottom: 0,
                                           right: 0)
            labelEdgeInsets = UIEdgeInsets(top: 0,
                                           left: space,
                                           bottom: 0,
                                           right: -space)
            contentEdgeInsets = UIEdgeInsets(top: 0,left: 0,bottom: 0,right: space)
        case .right:
            self.contentVerticalAlignment = .center
            var w_di = labelWidth + space/2
            if (labelWidth+imageWith+space) > bWidth{
                let labelWidth_f = self.titleLabel?.frame.width ?? 0
                w_di = labelWidth_f + space/2
            }
            imageEdgeInsets = UIEdgeInsets(top: 0,
                                           left: w_di,
                                           bottom: 0,
                                           right: -w_di)
            labelEdgeInsets = UIEdgeInsets(top: 0,
                                           left: -(imageWith+space/2),
                                           bottom: 0,
                                           right: imageWith+space/2)
            contentEdgeInsets = UIEdgeInsets(top: 0, left: space/2, bottom: 0, right: space/2.0)
        case .top:
            //img在上或者在下 一版按钮是水平垂直居中的
            self.contentHorizontalAlignment = .center
            self.contentVerticalAlignment = .center
            
            var w_di = labelWidth/2.0
            //如果内容宽度大于button宽度 改变计算方式
            if (labelWidth+imageWith+space) > bWidth{
                w_di = (bWidth - imageWith)/2
            }
            //考虑图片+显示文字宽度大于按钮总宽度的情况
            let labelWidth_f = self.titleLabel?.frame.width ?? 0
            if (imageWith+labelWidth_f+space)>bWidth{
                w_di = (bWidth - imageWith)/2
            }
            imageEdgeInsets = UIEdgeInsets(top: -(labelHeight+space),
                                           left: w_di,
                                           bottom: 0,
                                           right: -w_di)
            labelEdgeInsets = UIEdgeInsets(top: 0,
                                           left: -imageWith,
                                           bottom:-(space+imageHeight),
                                           right: 0)
            let h_di = (min_height+space)/2.0
            contentEdgeInsets = UIEdgeInsets(top:h_di,left: 0,bottom:h_di,right: 0)
        case .bottom:
            //img在上或者在下 一版按钮是水平垂直居中的
            self.contentHorizontalAlignment = .center
            self.contentVerticalAlignment = .center
            var w_di = labelWidth/2
            //如果内容宽度大于button宽度 改变计算方式
            if (labelWidth+imageWith+space) > bWidth{
                w_di = (bWidth - imageWith)/2
            }
          //考虑图片+显示文字宽度大于按钮总宽度的情况
            let labelWidth_f = self.titleLabel?.frame.width ?? 0
            if (imageWith+labelWidth_f+space)>bWidth{
                w_di = (bWidth - imageWith)/2
            }
            imageEdgeInsets = UIEdgeInsets(top: 0,
                                           left: w_di,
                                           bottom: -(labelHeight+space),
                                           right: -w_di)
            labelEdgeInsets = UIEdgeInsets(top: -(space+imageHeight),
                                           left: -imageWith,
                                           bottom: 0,
                                           right: 0)
            let h_di = (min_height+space)/2.0
            contentEdgeInsets = UIEdgeInsets(top:h_di, left: 0,bottom:h_di,right: 0)
        }
        self.contentEdgeInsets = contentEdgeInsets
        self.titleEdgeInsets = labelEdgeInsets
        self.imageEdgeInsets = imageEdgeInsets
    }
}
