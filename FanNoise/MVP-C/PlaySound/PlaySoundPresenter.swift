//
//  PlaySoundPresenter.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 02/05/2025.
//

import UIKit

protocol PlaySoundPresenter {
    func loadData(sounds: [Sound])
    func getOtherSound() -> [Sound]
    func getRandomSounds(sound: [Sound])
    func getLikeSound() -> [Sound]
    func getRandomVideos(videos:[Video])
    func getFunVideo() -> [Video]
}

class PlaySoundPresenterImpl: BasePresenter<PlaySoundView>, PlaySoundPresenter {
    
    private var otherSound: [Sound] = []
    private var likeSound: [Sound] = []
    private var funVideo: [Video] = []
    
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
}
