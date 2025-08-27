//
//  LanguageManager.swift
//  FanNoise
//
//  Created by ADMIN on 5/6/25.
//

import Foundation

class LanguageManager {
    static let shared = LanguageManager()
    
    private var choseLanguage: Language = .usa
    
    func getChoseLanguage() -> Language {
        return choseLanguage
    }
    
    func setChoseLanguage(_ newValue: Language) {
        self.choseLanguage = newValue
        AppManager.shared.setChoseLanguage(newValue)
    }
    
    func fetchChoseLanguage() {
        self.choseLanguage = AppManager.shared.getChoseLanguage()
    }
    
    class func localized(key: String) -> String? {
        guard let bundlePath = Bundle.main.path(forResource: shared.choseLanguage.code, ofType: "lproj") else {
            return nil
        }
        
        guard let bundle = Bundle(path: bundlePath) else {
            return nil
        }
        
        return NSLocalizedString(key, bundle: bundle, comment: String())
    }
}
