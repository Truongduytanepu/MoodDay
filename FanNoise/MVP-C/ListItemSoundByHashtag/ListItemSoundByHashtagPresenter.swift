//
//  ListItemSoundByHashtagPresenter.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 02/05/2025.
//

import UIKit
import GoogleMobileAds

protocol ListItemSoundByHashtagPresenter {
    func loadSoundByHashtag(_ nameHashtag: String)
    func numberOfSoundCategories(adsStep: Int) -> Int
    func updateListNativeAds(listNativeAd: [NativeAd])
    func getListNativeAd() -> [NativeAd]
    func getListSound() -> [Sound]
}

class ListItemSoundByHashtagPresenterImpl: BasePresenter<ListItemSoundByHashtagView>, ListItemSoundByHashtagPresenter {
    
    private var listNativeAd: [NativeAd] = []
    private var sounds: [Sound] = []
    
    func loadSoundByHashtag(_ nameHashtag: String){
        let result = HomeCategoryManager.shared.getSoundsByHashtag(nameHashtag)
        self.sounds = result
    }
    
    func getListSound() -> [Sound] {
        return self.sounds
    }

    func numberOfSoundCategories(adsStep: Int) -> Int {
        if listNativeAd.isEmpty {
            return self.sounds.count
        }
        
        return self.sounds.count + self.sounds.count / adsStep
    }
    
    func updateListNativeAds(listNativeAd: [NativeAd]) {
        self.listNativeAd = listNativeAd
    }
    
    func getListNativeAd() -> [NativeAd] {
        return self.listNativeAd
    }
}
