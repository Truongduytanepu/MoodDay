//
//  Language.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 22/04/2025.
//

import Foundation

class DataLanguage {
    
static let instance = DataLanguage()

private init() {} // Ngăn tạo instance khác

var languageList: [Language] = [
    Language(imageName: "ic_language_ARG", languageName: "Argentina", isSelectLanguage: false),
    Language(imageName: "ic_language_BRA", languageName: "Brasil", isSelectLanguage: false),
    Language(imageName: "ic_language_CHI", languageName: "China", isSelectLanguage: false),
    Language(imageName: "ic_language_CRO", languageName: "Crotia",isSelectLanguage: false),
    Language(imageName: "ic_language_FRA", languageName: "France",isSelectLanguage: false),
    Language(imageName: "ic_language_GER", languageName: "Germany",isSelectLanguage: false),
    Language(imageName: "ic_language_JAP", languageName: "Japan",isSelectLanguage: false),
    Language(imageName: "ic_language_KOR", languageName: "Korean",isSelectLanguage: false),
    Language(imageName: "ic_language_USA", languageName: "American",isSelectLanguage: false),
    Language(imageName: "ic_language_VIE", languageName: "Việt Nam",isSelectLanguage: false)
    ]
}
             
