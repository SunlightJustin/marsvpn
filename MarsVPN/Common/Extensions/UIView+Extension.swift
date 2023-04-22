//
//  UIView+Extension.swift
//  Kinker
//
//  Created by clove on 7/28/20.
//  Copyright © 2020 personal.Justin. All rights reserved.
//

import Foundation


extension UIView {
    func scale(to width: CGFloat?=nil) {
        if let width = width {
            scale(by: CGPoint(x: width/self.frame.size.width, y: width/self.frame.size.width))
            self.origin = .zero
        }
    }
}
