//
//  UIFont+Extension.swift
//  Fun
//
//  Created by zhoulei on 2019/4/10.
//  Copyright © 2019 W2. All rights reserved.
//

import Foundation

extension UIFont {
    class func systemFont(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: fontSize, weight: .regular)
    }
    class func lightSystemFont(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: fontSize, weight: .light)
    }
    class func regularSystemFont(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: fontSize, weight: .regular)
    }
    class func boldSystemFont(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: fontSize, weight: .bold)
    }
    class func mediumSystemFont(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: fontSize, weight: .medium)
    }
    class func semiboldSystemFont(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: fontSize, weight: .semibold)
    }
    class func heavySystemFont(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: fontSize, weight: .heavy)
    }
    class func heavyItalicFont(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont.heavySystemFont(ofSize: fontSize).boldItalic()
    }    
}

extension UIFont {
    func withTraits(traits:UIFontDescriptor.SymbolicTraits...) -> UIFont {
        guard let descriptor = self.fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits)) else { return UIFont.heavySystemFont(ofSize: 0) }
        return UIFont(descriptor: descriptor, size: 0)
    }
    func boldItalic() -> UIFont {
        return withTraits(traits: .traitBold, .traitItalic)
    }
    func italic() -> UIFont {
        return withTraits(traits: .traitItalic)
    }
}

extension UIFont {
    struct Montserrat {
        static func regularFont(ofSize fontSize: CGFloat) -> UIFont {
            return UIFont(name: "Montserrat-Regualr", size: fontSize) ?? systemFont(ofSize: fontSize)
        }
        static func mediumFont(ofSize fontSize: CGFloat) -> UIFont {
            return UIFont(name: "Montserrat-Medium", size: fontSize) ?? systemFont(ofSize: fontSize)
        }
        static func boldFont(ofSize fontSize: CGFloat) -> UIFont {
            return UIFont(name: "Montserrat-Bold", size: fontSize) ?? systemFont(ofSize: fontSize)
        }
    }
    class func regularMontserratFont(ofSize fontSize: CGFloat) -> UIFont {
        return Montserrat.regularFont(ofSize: fontSize)
    }
    class func mediumMontserratFont(ofSize fontSize: CGFloat) -> UIFont {
        return Montserrat.mediumFont(ofSize: fontSize)
    }
    class func boldMontserratFont(ofSize fontSize: CGFloat) -> UIFont {
        return Montserrat.boldFont(ofSize: fontSize)
    }
}


extension UIFont {
    class func showAllFamilyNames() {
        debugPrint("UIFont all family names = \(UIFont.familyNames)")
        debugPrint("UIFont font names for family name = \(UIFont.fontNames(forFamilyName: "Montserrat"))")

    }

}

