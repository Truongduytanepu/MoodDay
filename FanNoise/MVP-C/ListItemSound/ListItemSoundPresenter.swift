//
//  ListItemSoundPresenter.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 26/04/2025.
//

import UIKit
import GoogleMobileAds

protocol ListItemSoundPresenter {
    func getHashtag(sound: [Sound]) -> [String]
    func numberOfSoundCategories(sounds: [Sound], adsStep: Int) -> Int
    func numberOfVideoCategories(videos: [Video], adsStep: Int) -> Int
    func updateListNativeAds(listNativeAd: [NativeAd])
    func getListNativeAd() -> [NativeAd]
}

class ListItemSoundPresenterImpl: BasePresenter<ListItemSoundView>, ListItemSoundPresenter {
    
    private var listNativeAd: [NativeAd] = []
    
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
    
    func numberOfSoundCategories(sounds: [Sound], adsStep: Int) -> Int {
        if listNativeAd.isEmpty {
            return sounds.count
        }
        
        return sounds.count + sounds.count / adsStep
    }
    
    func numberOfVideoCategories(videos: [Video], adsStep: Int) -> Int {
        if listNativeAd.isEmpty {
            return videos.count
        }
        
        return videos.count + videos.count / adsStep
    }
    
    func updateListNativeAds(listNativeAd: [NativeAd]) {
        self.listNativeAd = listNativeAd
    }
    
    func getListNativeAd() -> [NativeAd] {
        return self.listNativeAd
    }
}
