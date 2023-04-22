//
//  UIView+AutoScaleSubviews.swift
//  SDM
//
//  Created by clove on 1/9/20.
//  Copyright © 2020 MS. All rights reserved.
//

import Foundation

extension UIView {
    public func scaleToFits(_ size:CGSize) {
        frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: size.width, height: size.height)
        let ratioX = size.width/bounds.size.width
        let ratioY = size.height/bounds.size.height
        for subview in subviews {
            let origin = subview.frame.origin
            let size = subview.frame.size
            if let label = subview as? UILabel {
                let v = label.font.pointSize * 1
                let size = roundf(Float(v))
                label.font = label.font.withSize(CGFloat(size))
            } else {
                subview.frame = CGRect(x: origin.x * ratioX, y: origin.y * ratioY, width: size.width * ratioX, height: size.height * ratioY)
            }
        }
    }
}
