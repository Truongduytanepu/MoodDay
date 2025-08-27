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
    
    func getChoseLanguage() -> Language {
        let rawValue = UserDefaults.standard.integer(forKey: "CHOSE_LANGUAGE")
        return Language(rawValue: rawValue) ?? .usa
    }
    
    func setChoseLanguage(_ newValue: Language) {
        UserDefaults.standard.set(newValue.rawValue, forKey: "CHOSE_LANGUAGE")
    }
}
