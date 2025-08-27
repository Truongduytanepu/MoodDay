//
//  UserDataRepository.swift
//  RankingFilterTop10
//
//  Created by ADMIN on 7/4/25.
//

import AVFoundation

class UserDataRepository {
    static let shared = UserDataRepository()
    
    private let userDefault = UserDefaults.standard
    
    private let firstShowIntro = "firstShowIntro"
    private let firstShowLanguage = "firstShowLanguage"
    
    // MARK: - First Show Intro
    func setFirstShowIntro(isFirst: Bool) {
        self.userDefault.setValue(isFirst, forKey: self.firstShowIntro)
    }
    
    func getFirstShowIntro() -> Bool {
        self.userDefault.bool(forKey: self.firstShowIntro)
    }
    
    // MARK: - First Show Language
    func setFirstShowLanguage(isFirst: Bool) {
        self.userDefault.setValue(isFirst, forKey: self.firstShowLanguage)
    }
    
    func getFirstShowLanguage() -> Bool {
        self.userDefault.bool(forKey: self.firstShowLanguage)
    }
}
