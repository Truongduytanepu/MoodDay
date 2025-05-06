//
//  AppManager.swift
//  FanNoise
//
//  Created by ADMIN on 5/6/25.
//

import Foundation
import UIKit

class AppManager {
    static let shared = AppManager()

    func hasSeenIntroGif() -> Bool {
        return UserDefaults.standard.bool(forKey: "hasSeenIntroGif")
    }
    
    func setHasSeenIntroGif() {
        UserDefaults.standard.set(true, forKey: "hasSeenIntroGif")
    }
}
