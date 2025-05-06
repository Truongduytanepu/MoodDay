//
//  LanguageManager.swift
//  FanNoise
//
//  Created by ADMIN on 5/6/25.
//

//import Foundation
//import SwiftKeychainWrapper
//
//class LanguageManager {
//  static let shared = LanguageManager()
//  
//  enum Keys {
//    static let choseLanguage = "CHOSE_LANGUAGE"
//  }
//  
//  private var choseLanguage: Language = .english
//  
//  func getChoseLanguage() -> Language {
//    return choseLanguage
//  }
//  
//  func setChoseLanguage(_ newValue: Language) {
//    self.choseLanguage = newValue
//    KeychainWrapper.standard.set(newValue.rawValue, forKey: Keys.choseLanguage)
//  }
//  
//  func fetchChoseLanguage() {
//    self.choseLanguage = Language(rawValue: KeychainWrapper.standard.integer(forKey: Keys.choseLanguage) ?? 0) ?? .english
//  }
//  
//  class func localized(key: String) -> String? {
//    guard let bundlePath = Bundle.main.path(forResource: shared.choseLanguage.code, ofType: "lproj") else {
//      return nil
//    }
//    guard let bundle = Bundle(path: bundlePath) else {
//      return nil
//    }
//    return NSLocalizedString(key, bundle: bundle, comment: String())
//  }
//}
