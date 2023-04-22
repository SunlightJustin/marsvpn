//
//  UIAlertViewController+Extension.swift
//  Kinker
//
//  Created by clove on 7/30/20.
//  Copyright © 2020 personal.Justin. All rights reserved.
//

import Foundation

public typealias EmptyCompletion = () -> Void

func presentReEnableNativePopup(title: String,
                                           message: String,
                                           allowButtonTitle: String?,
                                           denyButtonTitle: String?) {
       
       let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    if let allowButtonTitle = allowButtonTitle {
        let allow = UIAlertAction(title: allowButtonTitle, style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(allow)
    }
       
    if let denyButtonTitle = denyButtonTitle {
       let deny = UIAlertAction(title: denyButtonTitle, style: .cancel) { _ in
           alert.dismiss(animated: true, completion: nil)
       }
       alert.addAction(deny)
    }
       
       if var topController = UIApplication.shared.keyWindow?.rootViewController {
           while let presentedViewController = topController.presentedViewController {
               topController = presentedViewController
           }
           
           topController.present(alert, animated: true, completion: nil)
       }
}
   
func PresentAlert(title: String,
                                           message: String,
                                           allowButtonTitle: String?,
                  denyButtonTitle: String?,
                  okCompletion: EmptyCompletion? = nil,
                  cancelCompletion: EmptyCompletion? = nil) {

       let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

    if let allowButtonTitle = allowButtonTitle {
        let allow = UIAlertAction(title: allowButtonTitle, style: .default) { _ in
            okCompletion?()
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(allow)
    }

    if let denyButtonTitle = denyButtonTitle {
       let deny = UIAlertAction(title: denyButtonTitle, style: .cancel) { _ in
           cancelCompletion?()
           alert.dismiss(animated: true, completion: nil)
       }
       alert.addAction(deny)
    }

       if var topController = UIApplication.shared.keyWindow?.rootViewController {
           while let presentedViewController = topController.presentedViewController {
               topController = presentedViewController
           }

           topController.present(alert, animated: true, completion: nil)
       }
}

