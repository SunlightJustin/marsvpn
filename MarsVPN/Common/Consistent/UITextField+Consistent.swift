//
//  Con.swift
//  GOGOVPN
//
//  Created by Justin on 2022/9/8.
//

import UIKit

extension UITextField {
    
    class func createConsistent(_ placeholder: String,
                                width: CGFloat=UIScreen.main.bounds.size.width-24*2,
                                height: CGFloat=48,
                                font: UIFont = .mediumSystemFont(ofSize: 16),
                                textColor: UIColor?=UIColor.white) -> UITextField {
        
        let textField = UITextField(frame: CGRect.zero)
        textField.width = width
        textField.height = height
//        textField.contentMode = .center
        textField.leftViewMode = .always
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 18, height: 20))
        textField.font = font
        textField.left = 24
        textField.textColor = textColor
        textField.cornerRadius = 24
        textField.layer.borderColor = UIColor.white.cgColor
        textField.layer.borderWidth = 1
        textField.layer.masksToBounds = true
        textField.autocapitalizationType = .none
        textField.spellCheckingType = .no
        textField.autocorrectionType = .no
        textField.returnKeyType = .done
        textField.keyboardType = .default

//        textField.onReturn {
//            textField.resignFirstResponder()
//        }
        
        let attributes = [NSAttributedString.Key.font:UIFont.regularSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.white.alpha(0.8)]
        let attStr = NSAttributedString(string: placeholder, attributes: attributes)
        textField.attributedPlaceholder = attStr
        
        return textField
    }

}
