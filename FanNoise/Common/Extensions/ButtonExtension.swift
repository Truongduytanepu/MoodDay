//
//  ButtonExtension.swift
//  FanNoise
//
//  Created by ADMIN on 5/8/25.
//

import UIKit

@IBDesignable extension UIButton {
    @IBInspectable var localizeKey: String? {
        get {
            return self.title(for: .normal)
        } set {
            DispatchQueue.main.async {
                self.setTitle(newValue?.localized(), for: .normal)
            }
        }
    }
}
