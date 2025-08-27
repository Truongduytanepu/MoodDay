//
//  IntExtensions.swift
//  BabyPhoto
//
//  Created by Le Toan on 8/21/20.
//  Copyright © 2020 Solar. All rights reserved.
//

import Foundation

extension Int {
    func timeString() -> String {        
        let minute = self / 60 % 60
        let second = self % 60

        // return formated string
        return String(format: "%02d:%02d", minute, second)
    }
    
    func toString() -> String {
        return "\(self)"
    }
}
