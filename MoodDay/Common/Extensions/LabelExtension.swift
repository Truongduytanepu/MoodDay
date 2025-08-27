//
//  LabelExtension.swift
//  FanNoise
//
//  Created by ADMIN on 5/6/25.
//

import UIKit

@IBDesignable extension UILabel {
    @IBInspectable var localizeKey: String? {
        get {
            return self.text
        } set {
            DispatchQueue.main.async {
                self.text = newValue?.localized()
            }
        }
    }
}

extension UILabel {
    func applyFloorShadow() {
        self.layer.shadowOffset = CGSize(width: 0, height: 5)
        self.layer.shadowRadius = 0
        self.layer.shadowOpacity = 0.8
        self.layer.shadowColor = UIColor(rgb: 0x000000, alpha: 0.2).cgColor
    }
}
