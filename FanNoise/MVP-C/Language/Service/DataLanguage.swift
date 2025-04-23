//
//  DataLanguage.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 22/04/2025.
//

import Foundation

struct Language {
    var imageName : String
    var languageName : String
    var isSelectLanguage : Bool = false
    
    init(imageName: String, languageName: String, isSelectLanguage: Bool) {
        self.imageName = imageName
        self.languageName = languageName
        self.isSelectLanguage = isSelectLanguage
    }
}
