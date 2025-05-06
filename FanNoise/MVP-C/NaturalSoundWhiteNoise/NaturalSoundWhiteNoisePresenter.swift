//
//  NaturalSoundWhiteNoisePresenter.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 28/04/2025.
//

import UIKit

protocol NaturalSoundWhiteNoisePresenter {
    func loadData(categoryId: String) -> [SoundCategory]
    func getNumberOfItems(categoryId: String) -> Int
    func getSoundByCategoryName(nameCategory: String) -> [Sound]
    func getVideoByCategoryName(nameCategory: String) -> [Video]
}

class NaturalSoundWhiteNoisePresenterImpl: BasePresenter<NaturalSoundWhiteNoiseView>, NaturalSoundWhiteNoisePresenter {
    func getVideoByCategoryName(nameCategory: String) -> [Video] {
        return HomeCategoryManager.shared.getVideoByCategory(nameCategory)
    }

    func loadData(categoryId: String) -> [SoundCategory] {
        return HomeCategoryManager.shared.getSoundNameAndThumb(categoryId)
    }
    
    func getNumberOfItems(categoryId: String) -> Int {
        return HomeCategoryManager.shared.getSoundNameAndThumb(categoryId).count
    }
    
    func getSoundByCategoryName(nameCategory: String) -> [Sound] {
        return HomeCategoryManager.shared.getSoundByCategory(nameCategory)
    }
}
