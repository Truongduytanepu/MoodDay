//
//  ListItemSoundPresenter.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 26/04/2025.
//

import UIKit

protocol ListItemSoundPresenter {
    func getHashtag(sound: [Sound]) -> [String]
}

class ListItemSoundPresenterImpl: BasePresenter<ListItemSoundView>, ListItemSoundPresenter {
    
    func getHashtag(sound: [Sound]) -> [String] {
        var hashtags: [String] = []
        let soundData = sound
        
        // Bước 1: Thu thập và tách hashtag
        for sound in soundData {
            if let hashtagString = sound.hashtag {
                // Tách bằng "#", bỏ phần tử rỗng do split từ đầu chuỗi
                let tags = hashtagString.components(separatedBy: "#")
                    .filter { !$0.isEmpty }
                    .map { $0.trimmingCharacters(in: .whitespaces) }
                hashtags.append(contentsOf: tags)
            }
        }
        
        // Bước 2: Loại bỏ trùng lặp GIỮ NGUYÊN THỨ TỰ
        var uniqueHashtags = [String]()
        for tag in hashtags {
            if !uniqueHashtags.contains(tag) {
                uniqueHashtags.append(tag)
            }
        }
        
        return uniqueHashtags
    }
}
