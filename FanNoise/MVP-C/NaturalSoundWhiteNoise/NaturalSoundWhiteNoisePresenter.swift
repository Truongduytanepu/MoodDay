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
}

class NaturalSoundWhiteNoisePresenterImpl: BasePresenter<NaturalSoundWhiteNoiseView>, NaturalSoundWhiteNoisePresenter {


    func loadData(categoryId: String) -> [SoundCategory] {
        return HomeCategoryManager.shared.getSoundNameAndThumb(categoryId)
    }
    
    func getNumberOfItems(categoryId: String) -> Int {
        return HomeCategoryManager.shared.getSoundNameAndThumb(categoryId).count
    }
}
