//
//  AppFont.swift
//  Base_MVVM_Combine
//
//  Created by Chiến Nguyễn on 21/04/2025.
//

import UIKit

class AppFont {
    enum FontName: String {
        case rubikBlack = "Rubik-Black"
        case rubikBold = "Rubik-Bold"
        case rubikExtraBole = "Rubik-ExtraBold"
        case rubikSemiBold = "Rubik-SemiBold"
        case rubikRegular = "Rubik-Regular"
        case rubikMedium = "Rubik-Medium"
        case rubikItalic = "Rubik-Italic"
    }
    
    class func font(_ name: FontName, size: CGFloat) -> UIFont {
        guard let font = UIFont(name: name.rawValue, size: size) else {
            return UIFont.systemFont(ofSize: size)
        }
        
        return font
    }
}
