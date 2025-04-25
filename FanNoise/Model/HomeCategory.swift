//
//  CategoryHome.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 24/04/2025.
//

import Foundation

// MARK: - Category Model
@objc class HomeCategory: NSObject, Codable {
    let id: String?
    let name: String?
    let thumb: String?
    let index: Int?
    let sounds: [Sound]?
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
    let bgColor0: String?
    let bgColor1: String?
    let isRotate: Bool?
    let rotateFrame: Int?
    let isPremium: Bool?
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
}
