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
