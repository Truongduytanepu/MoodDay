//
//  AppFont.swift
//  Base_MVVM_Combine
//
//  Created by Chiến Nguyễn on 21/04/2025.
//

import UIKit

class AppFont {
    enum FontName: String {
        case mPLUS2Bold = "MPLUS2-Bold"
        case mPLUS2ExtraBold = "MPLUS2-ExtraBold"
        case mPLUS2Regular = "MPLUS2-Regular"
        case mPLUS2SemiBold = "MPLUS2-SemiBold"
        case mPLUS2Black = "MPLUS2-Black"
        case mPLUS2Medium = "MPLUS2-Medium"
        case lexendSemiBold = "Lexend-SemiBold"
    }
    
    class func font(_ name: FontName, size: CGFloat) -> UIFont {
        guard let font = UIFont(name: name.rawValue, size: size) else {
            return UIFont.systemFont(ofSize: size)
        }
        
        return font
    }
}
