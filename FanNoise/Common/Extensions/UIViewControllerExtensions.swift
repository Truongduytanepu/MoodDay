//
//  UIViewControllerExtensions.swift
//  BabyPhoto
//
//  Created by Thanh Vu on 7/17/20.
//  Copyright © 2020 Solar. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func topVC() -> UIViewController {
        if let navigation = self as? UINavigationController, !navigation.viewControllers.isEmpty {
            return navigation.topViewController!.topVC()
        }
        
        if let presentedVC = self.presentedViewController {
            return presentedVC.topVC()
        }
        
        return self
    }
    
    func postAlert(_ title: String, message: String, titleButton: String = "OK", completion: (() -> Void)?) {
        DispatchQueue.main.async(execute: { () -> Void in
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: titleButton, style: UIAlertAction.Style.default, handler: { _ in
                completion?()
            }))
            
            let popOver = alert.popoverPresentationController
            popOver?.sourceView  = self.view
            popOver?.sourceRect = self.view.bounds
            popOver?.permittedArrowDirections = UIPopoverArrowDirection.any
            
            self.present(alert, animated: true, completion: nil)
        })
    }
}
