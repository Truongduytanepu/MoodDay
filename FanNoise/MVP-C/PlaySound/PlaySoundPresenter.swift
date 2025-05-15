//
//  PlaySoundPresenter.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 02/05/2025.
//

import UIKit
import GoogleMobileAds

protocol PlaySoundPresenter {
    func loadData(sounds: [Sound])
    func getOtherSound() -> [Sound]
    func getRandomSounds(sound: [Sound])
    func getLikeSound() -> [Sound]
    func numberÒfLikeSound(adsStep: Int) -> Int
    func getRandomVideos(videos:[Video])
    func numberÒfOtherSound(adsStep: Int) -> Int
    func getFunVideo() -> [Video]
    func numberÒfFunVideo(adsStep: Int) -> Int
    func updateListNativeAds(listNativeAd: [NativeAd])
    func getListNativeAd() -> [NativeAd]
}

class PlaySoundPresenterImpl: BasePresenter<PlaySoundView>, PlaySoundPresenter {
    
    private var otherSound: [Sound] = []
    private var likeSound: [Sound] = []
    private var funVideo: [Video] = []
    private var listNativeAd: [NativeAd] = []
    
    func loadData(sounds: [Sound]) {
        self.otherSound = HomeCategoryManager.shared.getFilteredAndRandomSounds(soundsToExclude: sounds)
    }
    
    func getOtherSound() -> [Sound] {
        return self.otherSound
    }
    
    func getRandomSounds(sound: [Sound]) {
        let randomItems = sound.shuffled().prefix(10)
        self.likeSound.append(contentsOf: randomItems)
    }
    
    func getLikeSound() -> [Sound] {
        return self.likeSound
    }
    
    func getRandomVideos(videos: [Video]) {
        let randomItems = videos.shuffled().prefix(10)
        self.funVideo.append(contentsOf: randomItems)
    }
    
    func getFunVideo() -> [Video] {
        return self.funVideo
    }
    
    func updateListNativeAds(listNativeAd: [NativeAd]) {
        self.listNativeAd = listNativeAd
    }
    
    func getListNativeAd() -> [NativeAd] {
        return self.listNativeAd
    }
    
    func numberÒfLikeSound(adsStep: Int) -> Int {
        if self.listNativeAd.isEmpty {
            return self.likeSound.count
        }
        
        return self.likeSound.count + self.likeSound.count / adsStep
    }
    
    func numberÒfOtherSound(adsStep: Int) -> Int {
        if self.listNativeAd.isEmpty {
            return self.otherSound.count
        }
        
        return self.otherSound.count + self.otherSound.count / adsStep
    }
    
    func numberÒfFunVideo(adsStep: Int) -> Int {
        if self.listNativeAd.isEmpty {
            return self.funVideo.count
        }
        
        return self.funVideo.count + self.funVideo.count / adsStep
    }
}
