//
//  Language.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 22/04/2025.
//

import Foundation

enum Language: Int, CaseIterable {
  case brazil
  case china
  case croatia
  case france
  case germany
  case japan
  case korea
  case usa
  case vietnam
  
  var code: String {
    switch self {
    case .brazil:
      return "pt-BR"
    case .china:
      return "zh"
    case .croatia:
      return "hr"
    case .france:
      return "fr"
    case .germany:
      return "de"
    case .japan:
      return "ja"
    case .korea:
      return "ko"
    case .usa:
      return "en-US"
    case .vietnam:
      return "vi"
    }
  }
  
  var name: String {
    switch self {
    case .brazil:
      return "Brazil"
    case .china:
      return "China"
    case .croatia:
      return "Croatia"
    case .france:
      return "France"
    case .germany:
      return "Germany"
    case .japan:
      return "Japan"
    case .korea:
      return "Korea"
    case .usa:
      return "USA"
    case .vietnam:
      return "Vietnam"
    }
  }
  
  var ensign: String {
    switch self {
    case .brazil:
      return "ic_language_BRA"
    case .china:
      return "ic_language_CHI"
    case .croatia:
      return "ic_language_CRO"
    case .france:
      return "ic_language_FRA"
    case .germany:
      return "ic_language_GER"
    case .japan:
      return "ic_language_JAP"
    case .korea:
      return "ic_language_KOR"
    case .usa:
      return "ic_language_USA"
    case .vietnam:
      return "ic_language_VIE"
    }
  }
}
