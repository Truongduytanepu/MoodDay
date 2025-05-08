//
//  CategoryHome.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 24/04/2025.
//

import Foundation

let colorPairs: [(String, String)] = [
    ("FFF0DE", "FFE0BA"),
    ("C3B1E1", "E6DDF6"),
    ("E6E6FA", "DADAFF"),
    ("D4F1BE", "EBFFDC"),
    ("ACE7FF", "DEF5FF"),
    ("FFDEE9", "FFF0F5")
]

let hashtagPairs: [String] = [
    "#FanSound",
    "#SleepWithFan",
    "#WhiteNoise",
    "#FanNoise",
    "#RelaxingSound",
    "#SleepAid",
    "#CalmNoise",
    "#WhiteNoiseForSleep",
    "#FanVibes",
    "#DeepSleepSounds"
]
// MARK: - Category Model
@objc class HomeCategory: NSObject, Codable {
    let id: String?
    let name: String?
    let thumb: String?
    let index: Int?
    let sounds: [Sound]
    let videos: [Video]
}

@objc class Sound: NSObject, Codable {
    let id: String?
    let index: Int?
    let name: String?
    let category: SoundCategory?
    let frames: [String]?
    let source: String?
    let thumb: String?
    let hashtag: String?
    var bgColor0: String?
    var bgColor1: String?
    let isRotate: Bool?
    let rotateFrame: Int?
    let isPremium: Bool?
    
    func assignRandomColorsIfNeeded() {
        if bgColor0 == nil || bgColor1 == nil {
            let randomIndex = Int.random(in: 0..<colorPairs.count)
            bgColor0 = colorPairs[randomIndex].0
            bgColor1 = colorPairs[randomIndex].1
        }
    }
}

// MARK: - SoundCategory
@objc class SoundCategory: NSObject, Codable {
    let name: String?
    let thumb: String?
}

// MARK: - Video
@objc class Video: NSObject, Codable {
    let id: String?
    let index: Int?
    let name: String?
    let category: SoundCategory?
    let source: String?
    let thumb: String?
    let isPremium: Bool?
    var isPlay: Bool = false
    var hashtag: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case index
        case name
        case category
        case source
        case thumb
        case isPremium
        case hashtag
    }
    
    func assignRandomHashtagIfNeeded() {
        if hashtag == nil {
            // Lấy 3 hashtag ngẫu nhiên không trùng nhau
            let shuffled = hashtagPairs.shuffled()
            let selectedHashtags = shuffled.prefix(3)
            
            // Ghép thành chuỗi, mỗi hashtag cách nhau bởi dấu cách
            hashtag = selectedHashtags.joined(separator: " ")
        }
    }
}
