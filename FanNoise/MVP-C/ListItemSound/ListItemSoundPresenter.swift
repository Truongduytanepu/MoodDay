//
//  ListItemSoundPresenter.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 26/04/2025.
//

import UIKit

protocol ListItemSoundPresenter {
    func loadData(categoryId: String) -> [Sound]
    func getNumberOfItems(categoryId: String) -> Int
    func getHashtag(categoryId: String) -> [String]
}

class ListItemSoundPresenterImpl: BasePresenter<ListItemSoundView>, ListItemSoundPresenter {
    
    func loadData(categoryId: String) -> [Sound] {
        return HomeCategoryManager.shared.getSoundCategory(categoryId)
    }
    
    func getNumberOfItems(categoryId: String) -> Int {
        return HomeCategoryManager.shared.getSoundCategory(categoryId).count
    }
    
    func getHashtag(categoryId: String) -> [String] {
        var hashtags: [String] = []
        let soundData = HomeCategoryManager.shared.getSoundCategory(categoryId)
        
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
